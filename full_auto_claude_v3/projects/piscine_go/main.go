// Piscine Go - Go Language Basics
// Collection of exercises from 42 Go Piscine

package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

// Exercise 00: PrintAlphabet
func PrintAlphabet() {
	for c := 'a'; c <= 'z'; c++ {
		fmt.Print(string(c))
	}
	fmt.Println()
}

// Exercise 01: PrintReverseAlphabet
func PrintReverseAlphabet() {
	for c := 'z'; c >= 'a'; c-- {
		fmt.Print(string(c))
	}
	fmt.Println()
}

// Exercise 02: PrintDigits
func PrintDigits() {
	for d := '0'; d <= '9'; d++ {
		fmt.Print(string(d))
	}
	fmt.Println()
}

// Exercise 03: IsNegative
func IsNegative(n int) {
	if n < 0 {
		fmt.Println("T")
	} else {
		fmt.Println("F")
	}
}

// Exercise 04: PrintComb
func PrintComb() {
	for a := '0'; a <= '7'; a++ {
		for b := a + 1; b <= '8'; b++ {
			for c := b + 1; c <= '9'; c++ {
				fmt.Print(string(a), string(b), string(c))
				if a != '7' || b != '8' || c != '9' {
					fmt.Print(", ")
				}
			}
		}
	}
	fmt.Println()
}

// Exercise 05: PrintComb2
func PrintComb2() {
	for i := 0; i <= 98; i++ {
		for j := i + 1; j <= 99; j++ {
			fmt.Printf("%02d %02d", i, j)
			if i != 98 || j != 99 {
				fmt.Print(", ")
			}
		}
	}
	fmt.Println()
}

// Exercise 06: IterativeFactorial
func IterativeFactorial(n int) int {
	if n < 0 || n > 20 {
		return 0
	}
	result := 1
	for i := 2; i <= n; i++ {
		result *= i
	}
	return result
}

// Exercise 07: RecursiveFactorial
func RecursiveFactorial(n int) int {
	if n < 0 || n > 20 {
		return 0
	}
	if n <= 1 {
		return 1
	}
	return n * RecursiveFactorial(n-1)
}

// Exercise 08: IterativePower
func IterativePower(n, power int) int {
	if power < 0 {
		return 0
	}
	if power == 0 {
		return 1
	}
	result := 1
	for i := 0; i < power; i++ {
		result *= n
	}
	return result
}

// Exercise 09: RecursivePower
func RecursivePower(n, power int) int {
	if power < 0 {
		return 0
	}
	if power == 0 {
		return 1
	}
	return n * RecursivePower(n, power-1)
}

// Exercise 10: Sqrt
func Sqrt(n int) int {
	if n <= 0 {
		return 0
	}
	for i := 1; i*i <= n; i++ {
		if i*i == n {
			return i
		}
	}
	return 0
}

// Exercise 11: IsPrime
func IsPrime(n int) bool {
	if n <= 1 {
		return false
	}
	if n <= 3 {
		return true
	}
	if n%2 == 0 || n%3 == 0 {
		return false
	}
	for i := 5; i*i <= n; i += 6 {
		if n%i == 0 || n%(i+2) == 0 {
			return false
		}
	}
	return true
}

// Exercise 12: FindNextPrime
func FindNextPrime(n int) int {
	if n <= 2 {
		return 2
	}
	for !IsPrime(n) {
		n++
	}
	return n
}

// Exercise 13: Fibonacci
func Fibonacci(n int) int {
	if n < 0 {
		return -1
	}
	if n <= 1 {
		return n
	}
	a, b := 0, 1
	for i := 2; i <= n; i++ {
		a, b = b, a+b
	}
	return b
}

// String exercises

// Exercise: StrLen
func StrLen(s string) int {
	return len(s)
}

// Exercise: StrComp
func StrComp(a, b string) int {
	if a < b {
		return -1
	}
	if a > b {
		return 1
	}
	return 0
}

// Exercise: StrReverse
func StrReverse(s string) string {
	runes := []rune(s)
	for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
		runes[i], runes[j] = runes[j], runes[i]
	}
	return string(runes)
}

// Exercise: IsAlpha
func IsAlpha(s string) bool {
	for _, c := range s {
		if !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')) {
			return false
		}
	}
	return len(s) > 0
}

// Exercise: IsNumeric
func IsNumeric(s string) bool {
	for _, c := range s {
		if c < '0' || c > '9' {
			return false
		}
	}
	return len(s) > 0
}

// Exercise: IsAlphaNumeric
func IsAlphaNumeric(s string) bool {
	for _, c := range s {
		if !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')) {
			return false
		}
	}
	return len(s) > 0
}

// Exercise: IsLower
func IsLower(s string) bool {
	for _, c := range s {
		if c < 'a' || c > 'z' {
			return false
		}
	}
	return len(s) > 0
}

// Exercise: IsUpper
func IsUpper(s string) bool {
	for _, c := range s {
		if c < 'A' || c > 'Z' {
			return false
		}
	}
	return len(s) > 0
}

// Exercise: ToLower
func ToLower(s string) string {
	result := ""
	for _, c := range s {
		if c >= 'A' && c <= 'Z' {
			result += string(c + 32)
		} else {
			result += string(c)
		}
	}
	return result
}

// Exercise: ToUpper
func ToUpper(s string) string {
	result := ""
	for _, c := range s {
		if c >= 'a' && c <= 'z' {
			result += string(c - 32)
		} else {
			result += string(c)
		}
	}
	return result
}

// Exercise: Capitalize
func Capitalize(s string) string {
	runes := []rune(strings.ToLower(s))
	capitalize := true
	for i, c := range runes {
		if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') {
			if capitalize && c >= 'a' && c <= 'z' {
				runes[i] = c - 32
			}
			capitalize = false
		} else {
			capitalize = true
		}
	}
	return string(runes)
}

// Exercise: Split
func Split(s, sep string) []string {
	return strings.Split(s, sep)
}

// Exercise: Join
func Join(strs []string, sep string) string {
	return strings.Join(strs, sep)
}

// Exercise: Atoi
func Atoi(s string) int {
	n, _ := strconv.Atoi(s)
	return n
}

// Exercise: Itoa
func Itoa(n int) string {
	return strconv.Itoa(n)
}

// Sorting exercises

// Exercise: SortIntSlice
func SortIntSlice(s []int) {
	for i := 0; i < len(s); i++ {
		for j := i + 1; j < len(s); j++ {
			if s[j] < s[i] {
				s[i], s[j] = s[j], s[i]
			}
		}
	}
}

// Exercise: SortStringSlice
func SortStringSlice(s []string) {
	for i := 0; i < len(s); i++ {
		for j := i + 1; j < len(s); j++ {
			if s[j] < s[i] {
				s[i], s[j] = s[j], s[i]
			}
		}
	}
}

// Map exercises

// Exercise: Map (apply function to slice)
func Map(f func(int) bool, a []int) []bool {
	result := make([]bool, len(a))
	for i, v := range a {
		result[i] = f(v)
	}
	return result
}

// Exercise: Any (check if any element satisfies condition)
func Any(f func(int) bool, a []int) bool {
	for _, v := range a {
		if f(v) {
			return true
		}
	}
	return false
}

// Exercise: All (check if all elements satisfy condition)
func All(f func(int) bool, a []int) bool {
	for _, v := range a {
		if !f(v) {
			return false
		}
	}
	return true
}

// Exercise: Filter
func Filter(f func(int) bool, a []int) []int {
	var result []int
	for _, v := range a {
		if f(v) {
			result = append(result, v)
		}
	}
	return result
}

// Exercise: Reduce
func Reduce(f func(int, int) int, a []int, initial int) int {
	result := initial
	for _, v := range a {
		result = f(result, v)
	}
	return result
}

// Demo function
func runDemo() {
	fmt.Println("=== Piscine Go Demo ===")
	fmt.Println()

	fmt.Println("PrintAlphabet:")
	PrintAlphabet()

	fmt.Println("\nPrintReverseAlphabet:")
	PrintReverseAlphabet()

	fmt.Println("\nPrintDigits:")
	PrintDigits()

	fmt.Println("\nIsNegative(-5):")
	IsNegative(-5)

	fmt.Println("\nIterativeFactorial(5):", IterativeFactorial(5))
	fmt.Println("RecursiveFactorial(5):", RecursiveFactorial(5))

	fmt.Println("\nIterativePower(2, 10):", IterativePower(2, 10))
	fmt.Println("RecursivePower(2, 10):", RecursivePower(2, 10))

	fmt.Println("\nSqrt(144):", Sqrt(144))
	fmt.Println("Sqrt(100):", Sqrt(100))

	fmt.Println("\nIsPrime(17):", IsPrime(17))
	fmt.Println("IsPrime(18):", IsPrime(18))

	fmt.Println("\nFindNextPrime(14):", FindNextPrime(14))

	fmt.Println("\nFibonacci(10):", Fibonacci(10))

	fmt.Println("\n--- String Functions ---")
	fmt.Println("StrLen('Hello'):", StrLen("Hello"))
	fmt.Println("StrReverse('Hello'):", StrReverse("Hello"))
	fmt.Println("ToUpper('hello'):", ToUpper("hello"))
	fmt.Println("ToLower('HELLO'):", ToLower("HELLO"))
	fmt.Println("Capitalize('hello world'):", Capitalize("hello world"))
	fmt.Println("IsAlpha('abc'):", IsAlpha("abc"))
	fmt.Println("IsNumeric('123'):", IsNumeric("123"))

	fmt.Println("\n--- Slice Functions ---")
	nums := []int{5, 2, 8, 1, 9}
	fmt.Println("Original:", nums)
	SortIntSlice(nums)
	fmt.Println("Sorted:", nums)

	fmt.Println("\nFilter even numbers from [1,2,3,4,5]:")
	evens := Filter(func(n int) bool { return n%2 == 0 }, []int{1, 2, 3, 4, 5})
	fmt.Println("Result:", evens)

	fmt.Println("\nReduce (sum) [1,2,3,4,5]:")
	sum := Reduce(func(a, b int) int { return a + b }, []int{1, 2, 3, 4, 5}, 0)
	fmt.Println("Result:", sum)
}

func main() {
	if len(os.Args) > 1 && os.Args[1] == "demo" {
		runDemo()
	} else {
		fmt.Println("Piscine Go - Go Language Exercises")
		fmt.Println("\nUsage: go run main.go demo")
		fmt.Println("\nAvailable functions:")
		fmt.Println("  - PrintAlphabet, PrintReverseAlphabet, PrintDigits")
		fmt.Println("  - IsNegative, PrintComb, PrintComb2")
		fmt.Println("  - IterativeFactorial, RecursiveFactorial")
		fmt.Println("  - IterativePower, RecursivePower")
		fmt.Println("  - Sqrt, IsPrime, FindNextPrime, Fibonacci")
		fmt.Println("  - String: StrLen, StrReverse, ToUpper, ToLower, Capitalize")
		fmt.Println("  - Slices: SortIntSlice, Filter, Map, Reduce, Any, All")
	}
}
