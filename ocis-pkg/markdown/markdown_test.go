package markdown

import (
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var (
	SmallMarkdown = `# Title

some abstract description

## SubTitle 1

subtitle one description

## SubTitle 2

subtitle two description

### Subpoint to SubTitle 2

description to subpoint
`
	SmallMD = MD{
		Headings: []Heading{
			{Level: 1, Header: "Title", Content: "some abstract description\n"},
			{Level: 2, Header: "SubTitle 1", Content: "subtitle one description\n"},
			{Level: 2, Header: "SubTitle 2", Content: "subtitle two description\n"},
			{Level: 3, Header: "Subpoint to SubTitle 2", Content: "description to subpoint\n"},
		},
	}
)

var _ = Describe("TestMarkdown", func() {
	DescribeTable("Conversion works both ways",
		func(mdfile string, expectedMD MD) {
			md := NewMD([]byte(mdfile))

			Expect(len(md.Headings)).To(Equal(len(expectedMD.Headings)))
			for i, h := range md.Headings {
				Expect(h).To(Equal(expectedMD.Headings[i]))
			}
			Expect(string(md.Bytes())).To(Equal(mdfile))
		},
		Entry("converts a small markdown", SmallMarkdown, SmallMD),
	)
})
