package svc

import (
	"context"
	"embed"
	"fmt"
	"io/fs"
	"path/filepath"

	gateway "github.com/cs3org/go-cs3apis/cs3/gateway/v1beta1"
	rpc "github.com/cs3org/go-cs3apis/cs3/rpc/v1beta1"
	storageprovider "github.com/cs3org/go-cs3apis/cs3/storage/provider/v1beta1"
	v1beta1 "github.com/cs3org/go-cs3apis/cs3/types/v1beta1"
	"github.com/cs3org/reva/v2/pkg/storage/utils/metadata"
	"github.com/cs3org/reva/v2/pkg/storagespace"
	"github.com/cs3org/reva/v2/pkg/utils"
	"github.com/owncloud/ocis/v2/ocis-pkg/l10n"
)

var (
	//go:embed spacetemplate/*
	_spaceTemplateFS embed.FS

	//go:embed l10n/locale
	_localeFS embed.FS

	// subfolder where the translation files are stored
	_localeSubPath = "l10n/locale"

	// name of the secret space folder
	_spaceFolderName = ".space"

	// path to the image file
	_imagepath = "spacetemplate/image.png"

	// text for the readme.md file
	_readmeText = l10n.Template("Here you can add a description for this Space.")

	// name of the readme.md file
	_readmeName = "readme.md"

	// domain of the graph service (transifex)
	_domain = "graph"

	// HeaderAcceptLanguage is the header key for the accept-language header
	HeaderAcceptLanguage = "Accept-Language"

	// TemplateParameter is the key for the template parameter in the request
	TemplateParameter = "template"
)

func (g Graph) applySpaceTemplate(ctx context.Context, gwc gateway.GatewayAPIClient, root *storageprovider.ResourceId, template string, locale string) error {
	switch template {
	default:
		fallthrough
	case "none":
		return nil
	case "default":
		return g.applyDefaultTemplate(ctx, gwc, root, locale)
	}
}

func (g Graph) applyDefaultTemplate(ctx context.Context, gwc gateway.GatewayAPIClient, root *storageprovider.ResourceId, locale string) error {
	mdc := metadata.NewCS3(g.config.Reva.Address, g.config.Spaces.StorageUsersAddress)
	mdc.SpaceRoot = root

	var opaque *v1beta1.Opaque

	// create .space folder
	if err := mdc.MakeDirIfNotExist(ctx, _spaceFolderName); err != nil {
		return err
	}

	// upload space image
	iid, err := imageUpload(ctx, mdc)
	if err != nil {
		return err
	}
	opaque = utils.AppendPlainToOpaque(opaque, SpaceImageSpecialFolderName, iid)

	// upload readme.md
	rid, err := readmeUpload(ctx, mdc, locale, g.config.Spaces.DefaultLanguage)
	if err != nil {
		return err
	}
	opaque = utils.AppendPlainToOpaque(opaque, ReadmeSpecialFolderName, rid)

	// update space
	resp, err := gwc.UpdateStorageSpace(ctx, &storageprovider.UpdateStorageSpaceRequest{
		StorageSpace: &storageprovider.StorageSpace{
			Id: &storageprovider.StorageSpaceId{
				OpaqueId: storagespace.FormatResourceID(*root),
			},
			Root:   root,
			Opaque: opaque,
		},
	})
	switch {
	case err != nil:
		return err
	case resp.GetStatus().GetCode() != rpc.Code_CODE_OK:
		return fmt.Errorf("could not update storage space: %s", resp.GetStatus().GetMessage())
	default:
		return nil
	}
}

func imageUpload(ctx context.Context, mdc *metadata.CS3) (string, error) {
	b, err := fs.ReadFile(_spaceTemplateFS, _imagepath)
	if err != nil {
		return "", err
	}
	res, err := mdc.Upload(ctx, metadata.UploadRequest{
		Path:    filepath.Join(_spaceFolderName, filepath.Base(_imagepath)),
		Content: b,
	})
	if err != nil {
		return "", err
	}
	return res.FileID, nil
}

func readmeUpload(ctx context.Context, mdc *metadata.CS3, locale string, defaultLocale string) (string, error) {
	t := l10n.NewTranslatorFromCommonConfig(defaultLocale, _domain, "", _localeFS, _localeSubPath)
	res, err := mdc.Upload(ctx, metadata.UploadRequest{
		Path:    filepath.Join(_spaceFolderName, _readmeName),
		Content: []byte(t.Translate(_readmeText, locale)),
	})
	if err != nil {
		return "", err
	}
	return res.FileID, nil
}
