package main

import (
	"bytes"
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
		var errors []error
		var sentence string
		sentence = "... hrmm ..."
		repos, err := APIClient.ListRepo([]string{})

		if err != nil {
			fmt.Printf("ERR! %v\n", err)
			errors = append(errors, err)
		} else {
			// Again ... silly ... but compiler doesn't know its used in a view
			sentence = fmt.Sprintf("Got repo name : %v\n", repos[0])
			fmt.Printf("Loaded %v repos", len(repos))
		}
		var fileContents bytes.Buffer
		err = APIClient.GetFile("dummy", "master", "dummy_file.txt", 0, 0, "", true, nil, &fileContents)
		if err != nil {
			fmt.Printf("error getting file: %v\n", err)
			errors = append(errors, err)
		} else {
			sentence = fileContents.String()
		}

		c.HTML(http.StatusOK, page, gin.H{
			"title":    "The Dowager Countess",
			"sentence": sentence,
			"errors":   errors,
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
