#!/usr/bin/env wolframscript

Print["Wolfram Language Engine version: ", $Version]

Export["example_plot3d.pdf", Plot3D[Sin[x y], {x,-Pi,Pi}, {y,-Pi,Pi}]]

sol:= Integrate[1/(1 + x^3), x]
Print[TeXForm[sol]]

fun:= Sin[Sqrt[x^2 + y^2]]/Sqrt[x^2 + y^2]
Export["ripple.pdf",
Plot3D[fun, {x, -5*Pi, 5*Pi}, {y, -5*Pi, 5*Pi},
    PlotPoints -> 100, BoxRatios -> {1, 1, 0.2},
    PlotRange -> All]
]
