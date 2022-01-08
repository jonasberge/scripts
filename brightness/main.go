package main

import (
	"errors"
	"fmt"
	"log"
	"math"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

const GET_BRIGHTNESS = "xrandr --current --verbose | awk '/Brightness/ { print $2; exit }'"
const SET_BRIGHTNESS = "xrandr --output HDMI-A-0 --brightness %f"

func execute(command string) (out string, err error) {
	cmd := exec.Command("bash", "-c", command)
	data, err := cmd.Output()
	out = string(data)
	return
}

func getBrightness() (float32, error) {
	out, err := execute(GET_BRIGHTNESS)
	if err != nil {
		return 0, err
	}
	value, err := strconv.ParseFloat(strings.TrimSpace(out), 32)
	return float32(value), err
}

func setBrightness(value float32) (err error) {
	_, err = execute(fmt.Sprintf(SET_BRIGHTNESS, value))
	return
}

const STEP_COUNT = 100
const MAX_VALUE = 10000
const MIN_BRIGHTNESS = 0.3
const MAX_BRIGHTNESS = 1.0

var R = (STEP_COUNT * math.Log2(2)) / math.Log2(MAX_VALUE)

// https://diarmuid.ie/blog/pwm-exponential-led-fading-on-arduino-or-other-platforms
func stepBrightness(step int) float32 {
	y := math.Pow(2, float64(step) / R) - 1
	value := float32(y) / MAX_VALUE
	return MIN_BRIGHTNESS + value * (MAX_BRIGHTNESS - MIN_BRIGHTNESS)
}

func brightnessNearestStep(value float32) int {
	// get a good enough guess for the current step value from the brightness
	// only used when the current step is not stored in a file
	// so it doesn't have to be extremely accurate.
	value = (value - MIN_BRIGHTNESS) / (MAX_BRIGHTNESS - MIN_BRIGHTNESS)
	return int(math.Log2(float64(value * MAX_VALUE + 1)) * R)
}

func decodeData(data string) (step, stepCount int, err error) {
	parts := strings.Split(data, "/")
	if len(parts) != 2 {
		err = errors.New("expected two parts in data")
		return
	}
	step_, err := strconv.ParseInt(parts[0], 10, 32)
	if err != nil {
		return
	}
	stepCount_, err := strconv.ParseInt(parts[1], 10, 32)
	step = int(step_)
	stepCount = int(stepCount_)
	return
}

func encodeData(step, stepCount int) (data string) {
	return fmt.Sprintf("%d/%d", step, stepCount)
}

func loadStep(filename string) (step int, err error) {
	data, err := os.ReadFile(filename)
	if err != nil {
		return
	}
	step, stepCount, err := decodeData(string(data))
	if err != nil {
		return
	}
	if stepCount != STEP_COUNT {
		var brightness float32
		brightness, err = getBrightness()
		if err != nil {
			return
		}
		step = brightnessNearestStep(brightness)
	}
	return
}

func saveStep(filename string, step int) error {
	data := []byte(encodeData(step, STEP_COUNT))
	return os.WriteFile(filename, data, 0644)
}

func nextStep(step, delta int) int {
	next := step + delta
	if next < 0 {
		return 0
	}
	if next > STEP_COUNT {
		return STEP_COUNT
	}
	return next
}

func main() {
	// simple:
	// - set lower and upper cap for brightness
	// Upper: 1.0 - That's the value I set with the hardware buttons
	// Lower: 0.1 // try 0.4 - current value in a dark room
	// 1. read brightness from xrandr
	// 2. get direction (brighter, dimmer) from arguments
	// 3. compute next brightness value (exponential calculation)
	// 4. set brightness value

	args := os.Args[1:]
	filename := args[0]

	var delta int
	switch args[1] {
	case "add": delta = +1
	case "sub": delta = -1
	default:
		log.Fatalln("expected 'add' or 'sub' as second argument")
	}

	step := 0
	if _, err := os.Stat(filename); err == nil {
		step, err = loadStep(filename)
		if err != nil {
			log.Fatalln(err)
		}
	} else {
		brightness, err := getBrightness()
		if err != nil {
			log.Fatalln(err)
		}
		step = brightnessNearestStep(brightness)
	}

	next := nextStep(step, delta)
	brightness := stepBrightness(next)

	err := setBrightness(brightness)
	if err != nil {
		log.Fatalln("failed to set brightness:", err)
	}

	fmt.Println(brightness)

	err = saveStep(filename, next)
	if err != nil {
		log.Fatalln(err)
	}
}
