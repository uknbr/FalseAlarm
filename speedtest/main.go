package main

import (
	"fmt"
	"os"
	"time"
	_ "time/tzdata"
	"log"
	"github.com/showwin/speedtest-go/speedtest"
	"github.com/influxdata/influxdb1-client/v2"
)

func getEnv(key, fallback string) string {
    value, exists := os.LookupEnv(key)
    if !exists {
        value = fallback
    }
    return value
}

func convertLatency(s time.Duration) float64 {
	return float64(s / time.Millisecond)
}

func influxDBClient() client.Client {
	c, err := client.NewHTTPClient(client.HTTPConfig{
		Addr:     "http://" + getEnv("INFLUX_HOST", "localhost") + ":" + getEnv("INFLUX_PORT", "8086"),
	})
	if err != nil {
		log.Fatalln("Error: ", err)
	}
	return c
}

func addMetrics(l float64, d float64, u float64) {
	var c client.Client = influxDBClient()

	bp, err := client.NewBatchPoints(client.BatchPointsConfig{
		Database:  getEnv("INFLUX_DB", "florindabox"),
		Precision: "s",
	})
	if err != nil {
		log.Fatalln("Error: ", err)
	}

	loc, err := time.LoadLocation(getEnv("SPEEDTEST_TZ", "America/Sao_Paulo"))
	if err != nil {
		panic(err)
	}

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
		"speedtest",
		tags,
		fields,
		time.Now().In(loc),
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
	fmt.Print("Looking for configuration...\n")
	var enable_influx bool
	env_enable_influx := getEnv("INFLUX_ENABLE", "false")
	if env_enable_influx == "false" {
		enable_influx = false
	} else {
		enable_influx = true
	}

	interval, err := time.ParseDuration(getEnv("SPEEDTEST_INTERVAL", "5m"))
	if err != nil {
		log.Fatal(err)
	}

	fmt.Print("Retrieving speedtest.net configuration...\n")
	user, _ := speedtest.FetchUserInfo()

	fmt.Print("Selecting best server based on ping...\n")
	serverList, _ := speedtest.FetchServerList(user)
	targets, _ := serverList.FindServer([]int{})

	fmt.Print("Testing download/upload speed\n")

	for true {
		for _, s := range targets {
			s.PingTest()
			s.DownloadTest(false)
			s.UploadTest(false)

			latency := convertLatency(s.Latency)
			fmt.Printf("[%s] Latency: %f ms\tDownload: %f Mbit/s\tUpload: %f Mbit/s\n", time.Now().Format("Jan 09, 2020 15:04:05"), latency, s.DLSpeed, s.ULSpeed)
			if enable_influx {
				addMetrics(latency, s.DLSpeed, s.ULSpeed)
			}
		}
		time.Sleep(interval)
	}
}