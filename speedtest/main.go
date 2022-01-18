package main

import (
	"fmt"
	"time"
	"log"
	"github.com/showwin/speedtest-go/speedtest"
	"github.com/influxdata/influxdb1-client/v2"
)

func convertLatency(s time.Duration) float64 {
	return float64(s / time.Millisecond)
}

func influxDBClient() client.Client {
	c, err := client.NewHTTPClient(client.HTTPConfig{
		Addr:     "http://localhost:8086",
	})
	if err != nil {
		log.Fatalln("Error: ", err)
	}
	return c
}

func addMetrics(c client.Client, l float64, d float64, u float64) {
	bp, err := client.NewBatchPoints(client.BatchPointsConfig{
		Database:  "speedtest",
		Precision: "s",
	})
	if err != nil {
		log.Fatalln("Error: ", err)
	}

	eventTime := time.Now().Add(time.Second * -20)

	tags := map[string]string{
		"cluster": "florindabox",
		"host":    "master",
	}

	fields := map[string]interface{}{
		"latency":  l,
		"download": d,
		"upload": u,
	}

	point, err := client.NewPoint(
		"speed_status",
		tags,
		fields,
		eventTime.Add(time.Second*10),
	)
	if err != nil {
		log.Fatalln("Error: ", err)
	}

	bp.AddPoint(point)

	err = c.Write(bp)
	if err != nil {
		log.Fatal(err)
	}
}

func main() {
	fmt.Print("Initializing InfluxDB...\n")
	c := influxDBClient()

	fmt.Print("Retrieving speedtest.net configuration...\n")
	user, _ := speedtest.FetchUserInfo()

	fmt.Print("Selecting best server based on ping...\n")
	serverList, _ := speedtest.FetchServerList(user)
	targets, _ := serverList.FindServer([]int{})

	fmt.Print("Testing download/upload speed\n")
	for _, s := range targets {
		s.PingTest()
		s.DownloadTest(false)
		s.UploadTest(false)

		latency := convertLatency(s.Latency)
		fmt.Printf("\nLatency: %f ms\nDownload: %f Mbit/s\nUpload: %f Mbit/s\n", latency, s.DLSpeed, s.ULSpeed)
		addMetrics(c, latency, s.DLSpeed, s.ULSpeed)
	}
}