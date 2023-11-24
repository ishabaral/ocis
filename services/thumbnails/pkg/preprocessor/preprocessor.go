package preprocessor

import (
	"archive/zip"
	"bufio"
	"bytes"
	"fmt"
	"image"
	"image/draw"
	"image/gif"
	"io"
	"math"
	"mime"
	"strings"

	"github.com/disintegration/imaging"
	"github.com/pkg/errors"
	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
	"golang.org/x/image/math/fixed"

	"github.com/dhowden/tag"
)

type FileConverter interface {
	Convert(r io.Reader) (interface{}, error)
}

type ImageDecoder struct{}

func (i ImageDecoder) Convert(r io.Reader) (interface{}, error) {
	img, err := imaging.Decode(r, imaging.AutoOrientation(true))
	if err != nil {
		return nil, errors.Wrap(err, `could not decode the image`)
	}
	return img, nil
}

type GifDecoder struct{}

func (i GifDecoder) Convert(r io.Reader) (interface{}, error) {
	img, err := gif.DecodeAll(r)
	if err != nil {
		return nil, errors.Wrap(err, `could not decode the image`)
	}
	return img, nil
}

type GgsDecoder struct{}

func (g GgsDecoder) Convert(r io.Reader) (interface{}, error) {
	geogebraThumbnail := "_slide0/geogebra_thumbnail.png"
	var buf bytes.Buffer
	_, err := io.Copy(&buf, r)
	if err != nil {
		return nil, err
	}
	zipReader, err := zip.NewReader(bytes.NewReader(buf.Bytes()), int64(buf.Len()))
	if err != nil {
		return nil, err
	}
	for _, file := range zipReader.File {
		if file.Name == geogebraThumbnail {
			thumbnail, err := file.Open()
			if err != nil {
				return nil, err
			}

			img, err := imaging.Decode(thumbnail, imaging.AutoOrientation(true))
			if err != nil {
				return nil, errors.Wrap(err, `could not decode the image`)
			}
			return img, nil
		}
	}
	return nil, errors.New(fmt.Sprintf("%s not found", geogebraThumbnail))
}

type AudioDecoder struct{}

func (i AudioDecoder) Convert(r io.Reader) (interface{}, error) {
	b, err := io.ReadAll(r)
	if err != nil {
		return nil, err
	}
	m, err := tag.ReadFrom(bytes.NewReader(b))
	if err != nil {
		return nil, err
	}

	picture := m.Picture()
	if picture == nil {
		return nil, errors.New(`could not extract image from audio file`)
	}

	converter := ForType(picture.MIMEType, nil)
	if converter == nil {
		return nil, errors.New(`could not find converter for image extraced from audio file`)
	}

	return converter.Convert(bytes.NewReader(picture.Data))
}

type TxtToImageConverter struct {
	fontLoader *FontLoader
}

func (t TxtToImageConverter) Convert(r io.Reader) (interface{}, error) {
	img := image.NewRGBA(image.Rect(0, 0, 640, 480))

	imgBounds := img.Bounds()
	draw.Draw(img, imgBounds, image.White, image.Point{}, draw.Src)

	fontSizeAsInt := int(math.Ceil(t.fontLoader.GetFaceOptSize()))
	margin := 10
	minX := fixed.I(imgBounds.Min.X + margin)
	maxX := fixed.I(imgBounds.Max.X - margin)
	maxY := fixed.I(imgBounds.Max.Y - margin)
	initialPoint := fixed.P(imgBounds.Min.X+margin, imgBounds.Min.Y+margin+fontSizeAsInt)
	canvas := &font.Drawer{
		Dst: img,
		Src: image.Black,
		Dot: initialPoint,
	}

	scriptList := t.fontLoader.GetScriptList()
	textAnalyzer := NewTextAnalyzer(scriptList)
	taOpts := AnalysisOpts{
		UseMergeMap: true,
		MergeMap:    DefaultMergeMap,
	}

	scanner := bufio.NewScanner(r)
Scan: // Label for the scanner loop, so we can break it easily
	for scanner.Scan() {
		txt := scanner.Text()
		height := fixed.I(fontSizeAsInt) // reset to default height

		textResult := textAnalyzer.AnalyzeString(txt, taOpts)
		textResult.MergeCommon(DefaultMergeMap)

		for _, sRange := range textResult.ScriptRanges {
			targetFontFace, _ := t.fontLoader.LoadFaceForScript(sRange.TargetScript)
			// if the target script is "_unknown" it's expected that the loaded face
			// uses the default font
			faceHeight := targetFontFace.Face.Metrics().Height
			if faceHeight > height {
				height = faceHeight
			}

			canvas.Face = targetFontFace.Face
			initialByte := sRange.Low
			for _, sRangeSpace := range sRange.Spaces {
				if canvas.Dot.Y > maxY {
					break Scan
				}
				drawWord(canvas, textResult.Text[initialByte:sRangeSpace], minX, maxX, height, maxY, true)
				initialByte = sRangeSpace
			}
			if initialByte <= sRange.High {
				// some bytes left to be written
				if canvas.Dot.Y > maxY {
					break Scan
				}
				drawWord(canvas, textResult.Text[initialByte:sRange.High+1], minX, maxX, height, maxY, len(sRange.Spaces) > 0)
			}
		}

		canvas.Dot.X = minX
		canvas.Dot.Y += height.Mul(fixed.Int26_6(1<<6 + 1<<5)) // height * 1.5

		if canvas.Dot.Y > maxY {
			break
		}
	}
	return img, scanner.Err()
}

// Draw the word in the canvas. The mixX and maxX defines the drawable range
// (X axis) where the word can be drawn (in case the word is too big and doesn't
// fit in the canvas), and the incY defines the increment in the Y axis if we
// need to draw the word in a new line
//
// Note that the word will likely start with a white space char
func drawWord(canvas *font.Drawer, word string, minX, maxX, incY, maxY fixed.Int26_6, goToNewLine bool) {
	bbox, _ := canvas.BoundString(word)
	if bbox.Max.X <= maxX {
		// word fits in the current line
		canvas.DrawString(word)
	} else {
		// word doesn't fit -> retry in a new line
		trimmedWord := strings.TrimSpace(word)
		oldDot := canvas.Dot

		canvas.Dot.X = minX
		canvas.Dot.Y += incY
		bbox2, _ := canvas.BoundString(trimmedWord)
		if goToNewLine && bbox2.Max.X <= maxX {
			if canvas.Dot.Y > maxY {
				// Don't draw if we're over the Y limit
				return
			}
			canvas.DrawString(trimmedWord)
		} else {
			// word doesn't fit in a new line -> draw as many chars as possible
			canvas.Dot = oldDot
			for _, char := range trimmedWord {
				charBytes := []byte(string(char))
				bbox3, _ := canvas.BoundBytes(charBytes)
				if bbox3.Max.X > maxX {
					canvas.Dot.X = minX
					canvas.Dot.Y += incY
					if canvas.Dot.Y > maxY {
						// Don't draw if we're over the Y limit
						return
					}
				}
				canvas.DrawBytes(charBytes)
			}
		}
	}
}

func ForType(mimeType string, opts map[string]interface{}) FileConverter {
	// We can ignore the error here because we parse it in IsMimeTypeSupported before and if it fails
	// return the service call. So we should only get here when the mimeType parses fine.
	mimeType, _, _ = mime.ParseMediaType(mimeType)
	switch mimeType {
	case "text/plain":
		fontFileMap := ""
		fontFaceOpts := &opentype.FaceOptions{
			Size:    12,
			DPI:     72,
			Hinting: font.HintingNone,
		}

		if optedFontFileMap, ok := opts["fontFileMap"]; ok {
			if stringFontFileMap, ok := optedFontFileMap.(string); ok {
				fontFileMap = stringFontFileMap
			}
		}

		if optedFontFaceOpts, ok := opts["fontFaceOpts"]; ok {
			if typedFontFaceOpts, ok := optedFontFaceOpts.(*opentype.FaceOptions); ok {
				fontFaceOpts = typedFontFaceOpts
			}
		}

		fontLoader, err := NewFontLoader(fontFileMap, fontFaceOpts)
		if err != nil {
			// if couldn't create the FontLoader with the specified fontFileMap,
			// try to use the default font
			fontLoader, _ = NewFontLoader("", fontFaceOpts)
		}
		return TxtToImageConverter{
			fontLoader: fontLoader,
		}
	case "application/vnd.geogebra.slides":
		return GgsDecoder{}
	case "image/gif":
		return GifDecoder{}
	case "audio/flac":
		fallthrough
	case "audio/mpeg":
		fallthrough
	case "audio/ogg":
		return AudioDecoder{}
	default:
		return ImageDecoder{}
	}
}
