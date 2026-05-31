<#
.SYNOPSIS
    Adds a uniform print border (bleed / safe margin) around exported card images.

.DESCRIPTION
    Post-processing helper for the wsmtools export. MSE's write_image_file() cannot pad
    an image, so this script does it afterwards using the built-in .NET System.Drawing
    (no external tools like ImageMagick required).

    The border width is specified in millimetres and converted to pixels based on each
    image's actual width relative to the physical card width. This means the border stays
    a true 5mm regardless of the zoom multiplier used at export time (a higher zoom simply
    produces more border pixels).

    Supported formats: jpg/jpeg, png, tiff, bmp. The output keeps the original format.

.PARAMETER Path
    Folder containing the exported card images. Defaults to the current directory.

.PARAMETER BorderMM
    Border width in millimetres, applied to all four sides. Default: 5.

.PARAMETER Color
    Border fill colour. "White" (default), "Black", or "Transparent".
    Transparent only works for png/tiff; for jpg/bmp it falls back to White.

.PARAMETER CardWidthMM
    Physical card width in millimetres, used to convert mm to pixels.
    Default 63.9 (448px / 178dpi for this plugin's standard card).

.PARAMETER OutDir
    Optional output folder. If omitted, images are overwritten in place.

.PARAMETER JpegQuality
    JPEG quality (1-100) when saving jpg/jpeg. Default: 95.

.EXAMPLE
    .\add-print-border.ps1 -Path .\exported-cards

.EXAMPLE
    .\add-print-border.ps1 -Path .\exported-cards -BorderMM 5 -Color White -OutDir .\with-border
#>
[CmdletBinding()]
param(
    [string]$Path = ".",
    [double]$BorderMM = 5,
    [ValidateSet("White", "Black", "Transparent")]
    [string]$Color = "White",
    [double]$CardWidthMM = 63.9,
    [string]$OutDir,
    [ValidateRange(1, 100)]
    [int]$JpegQuality = 95
)

Add-Type -AssemblyName System.Drawing

$extensions = @(".jpg", ".jpeg", ".png", ".tiff", ".tif", ".bmp")

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Path not found: $Path"
}

if ($OutDir -and -not (Test-Path -LiteralPath $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

# JPEG encoder + quality param (reused for every jpg saved)
$jpegEncoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq "image/jpeg" }
$jpegParams = New-Object System.Drawing.Imaging.EncoderParameters 1
$jpegParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
    [System.Drawing.Imaging.Encoder]::Quality, [long]$JpegQuality)

$files = Get-ChildItem -LiteralPath $Path -File |
    Where-Object { $extensions -contains $_.Extension.ToLower() }

if (-not $files) {
    Write-Warning "No images found in '$Path' with extensions: $($extensions -join ', ')"
    return
}

$count = 0
foreach ($file in $files) {
    $ext = $file.Extension.ToLower()

    $src = [System.Drawing.Image]::FromFile($file.FullName)
    try {
        # px per mm from this image's real width, then border in px.
        $pxPerMM  = $src.Width / $CardWidthMM
        $borderPx = [int][Math]::Round($pxPerMM * $BorderMM)

        $newW = $src.Width + 2 * $borderPx
        $newH = $src.Height + 2 * $borderPx

        # Transparent only valid for formats with an alpha channel.
        $useColor = $Color
        if ($Color -eq "Transparent" -and ($ext -eq ".jpg" -or $ext -eq ".jpeg" -or $ext -eq ".bmp")) {
            Write-Warning "$($file.Name): '$ext' has no alpha channel; using White instead of Transparent."
            $useColor = "White"
        }

        $pixelFormat = if ($useColor -eq "Transparent") {
            [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
        } else {
            [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
        }

        $dest = New-Object System.Drawing.Bitmap($newW, $newH, $pixelFormat)
        # Preserve print DPI so the physical size stays correct.
        $dest.SetResolution($src.HorizontalResolution, $src.VerticalResolution)

        $g = [System.Drawing.Graphics]::FromImage($dest)
        try {
            switch ($useColor) {
                "White"       { $g.Clear([System.Drawing.Color]::White) }
                "Black"       { $g.Clear([System.Drawing.Color]::Black) }
                "Transparent" { $g.Clear([System.Drawing.Color]::Transparent) }
            }
            $g.DrawImage($src, $borderPx, $borderPx, $src.Width, $src.Height)
        } finally {
            $g.Dispose()
        }

        $outPath = if ($OutDir) {
            Join-Path $OutDir $file.Name
        } else {
            $file.FullName
        }

        # FromFile locks the file; release before overwriting in place.
        if (-not $OutDir) {
            $src.Dispose()
            $src = $null
        }

        switch ($ext) {
            { $_ -in ".jpg", ".jpeg" } { $dest.Save($outPath, $jpegEncoder, $jpegParams) }
            ".png"                     { $dest.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png) }
            { $_ -in ".tiff", ".tif" } { $dest.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Tiff) }
            ".bmp"                     { $dest.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Bmp) }
        }

        $dest.Dispose()
        $count++
        Write-Host "[$($file.Name)] +${borderPx}px border -> ${newW}x${newH}"
    } finally {
        if ($src) { $src.Dispose() }
    }
}

Write-Host "Done. Processed $count image(s) with a ${BorderMM}mm $Color border."
