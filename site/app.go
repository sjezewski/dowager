package main

import (
	"github.com/gin-gonic/contrib/renders/multitemplate"
	"github.com/gin-gonic/gin"
	"github.com/sjezewski/dowager/site/asset"

	"github.com/pachyderm/pachyderm/src/client"
)

var router = gin.New()
var APIClient *client.APIClient
var assetHandler = asset.NewAssetHandler()

func init() {
	apiClient, _ := client.NewInCluster()
	APIClient = apiClient
	assets := router.Group("/assets")
	{
		assets.GET("/main.js", assetHandler.Serve)
		assets.GET("/codemirror.js", assetHandler.Serve)
	}
	router.HTMLRender = loadTemplates()
}

func loadTemplates() multitemplate.Render {
	templates := multitemplate.New()
	templates.AddFromFiles(
		"main",
		"views/base.html",
	)
	return templates
}

func main() {
}
