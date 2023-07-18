package main

import (
	"fmt"
	"time"

	"github.com/tsenart/vegeta/v12/lib"
)

func main() {
	rate := vegeta.Rate{Freq: 100, Per: time.Second}
	duration := 10 * time.Second

	targeter := vegeta.NewStaticTargeter(
		vegeta.Target{
			Method: "GET",
			URL:    "http://foo.localhost",
		},
		vegeta.Target{
			Method: "GET",
			URL:    "http://bar.localhost",
		},
	)

	attacker := vegeta.NewAttacker()

	var metrics vegeta.Metrics
	for res := range attacker.Attack(targeter, rate, duration, "") {
		metrics.Add(res)
	}
	metrics.Close()

	fmt.Printf("99th percentile: %s\n", metrics.Latencies.Quantile(0.99))
}
