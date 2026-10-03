param(
    [double]$Value,
    [string]$From,
    [string]$To
)

$From = $From.ToLower()
$To = $To.ToLower()

$result = $null

if ($From -eq "c" -and $To -eq "f") { $result = ($Value * 9/5) + 32 }
elseif ($From -eq "f" -and $To -eq "c") { $result = ($Value - 32) * 5/9 }
elseif ($From -eq "c" -and $To -eq "k") { $result = $Value + 273.15 }
elseif ($From -eq "k" -and $To -eq "c") { $result = $Value - 273.15 }
elseif ($From -eq "f" -and $To -eq "k") { $result = ($Value - 32) * 5/9 + 273.15 }
elseif ($From -eq "k" -and $To -eq "f") { $result = ($Value - 273.15) * 9/5 + 32 }
else {
    $length = @{ "km" = 1000; "m" = 1; "cm" = 0.01; "mi" = 1609.344; "ft" = 0.3048; "in" = 0.0254 }
    $weight = @{ "kg" = 1; "g" = 0.001; "lb" = 0.45359237; "oz" = 0.028349523125 }
    $volume = @{ "l" = 1; "ml" = 0.001; "gal" = 3.78541; "fl_oz" = 0.0295735 }
    $speed = @{ "mps" = 1; "kph" = 0.277778; "mph" = 0.44704 }
    $data = @{ "b" = 1; "kb" = 1024; "mb" = 1048576; "gb" = 1073741824; "tb" = 1099511627776 }

    if ($length.ContainsKey($From) -and $length.ContainsKey($To)) {
        $result = ($Value * $length[$From]) / $length[$To]
    } elseif ($weight.ContainsKey($From) -and $weight.ContainsKey($To)) {
        $result = ($Value * $weight[$From]) / $weight[$To]
    } elseif ($volume.ContainsKey($From) -and $volume.ContainsKey($To)) {
        $result = ($Value * $volume[$From]) / $volume[$To]
    } elseif ($speed.ContainsKey($From) -and $speed.ContainsKey($To)) {
        $result = ($Value * $speed[$From]) / $speed[$To]
    } elseif ($data.ContainsKey($From) -and $data.ContainsKey($To)) {
        $result = ($Value * $data[$From]) / $data[$To]
    }
}

if ($null -ne $result) {
    Write-Output "$result $To"
} else {
    Write-Error "Unsupported conversion from $From to $To"
}
