# Minimal GUT setup for Godot 4
# This is a simplified version for basic testing
extends Node
class_name GutTest

var _test_count = 0
var _pass_count = 0
var _fail_count = 0

func _ready():
	print("=== Running Tests ===")
	run_tests()
	print_summary()

func run_tests():
	# Override in test scripts
	pass

func assert_true(condition: bool, message: String = ""):
	_test_count += 1
	if condition:
		_pass_count += 1
		print("  ✓ PASS: ", message if message else "assertion passed")
	else:
		_fail_count += 1
		print("  ✗ FAIL: ", message if message else "assertion failed")

func assert_false(condition: bool, message: String = ""):
	assert_true(!condition, message)

func assert_eq(actual, expected, message: String = ""):
	_test_count += 1
	if actual == expected:
		_pass_count += 1
		print("  ✓ PASS: ", message if message else "values equal")
	else:
		_fail_count += 1
		print("  ✗ FAIL: ", message if message else "expected ", expected, " but got ", actual)

func assert_ne(actual, expected, message: String = ""):
	_test_count += 1
	if actual != expected:
		_pass_count += 1
		print("  ✓ PASS: ", message if message else "values not equal")
	else:
		_fail_count += 1
		print("  ✗ FAIL: ", message if message else "expected values to differ")

func print_summary():
	print("\n=== Test Summary ===")
	print("Total: ", _test_count)
	print("Passed: ", _pass_count)
	print("Failed: ", _fail_count)
	if _fail_count == 0:
		print("✓ All tests passed!")
	else:
		print("✗ Some tests failed")
