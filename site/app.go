package main

import (
	"fmt"
	"net/http"

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

func handle(page string) func(*gin.Context) {
	return func(c *gin.Context) {
		if gin.Mode() == "debug" {
			router.HTMLRender = loadTemplates()
		}

		c.HTML(http.StatusOK, page, gin.H{
			"title":    "The Dowager Countess",
			"sentence": "... hrmm ...",
		})

	}
}

func main() {
	fmt.Println("Starting main handler\n")
	router.GET("/", handle("main"))
	fmt.Println("Starting server")
	router.Run(":9080")
	fmt.Println("... started\n")
}
