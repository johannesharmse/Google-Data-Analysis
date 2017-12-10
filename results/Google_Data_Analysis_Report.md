Googe Data Analysis Report
================
Johannes Harmse

<br>

Google Data Visualisation
=========================

<br>

Hypothesis
----------

<br>

A Google user's browser history is dependent on his/her location due to having different interests when in different locations. <br> <br>

Methodology
-----------

<br>

We are using two datasets to test this hypothesis. Each Google user has his/her own personal data collection from Google. <br> <br>

For this analysis we need a Google user's location and browser history datasets. This is easily obtainable from [Google Data](https://support.google.com/accounts/answer/3024190?hl=en). <br> <br>

We want to visually compare different time periods and locations movement for a given user to determine whether the user's Google most popular search words stay consistent or changes over time and location. <br> <br>

If you ran the following scripts, your visualisation should be displayed below.

-   `../src/data_import.R` <br>

-   `../src/data_cleaning.R` <br>

-   `../src/data_visuaulisation.R` <br> <br>

Results
-------

<!--html_preserve-->
<html>
<head>
    <meta charset="utf-8" />
    <meta name="generator" content="R package animation 2.5">
    <title>Google Location Data</title>
    <link rel="stylesheet" href="css/reset.css" />
    <link rel="stylesheet" href="css/styles.css" />
    <link rel="stylesheet" href="css/scianimator.css" />

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3/styles/github.min.css">

    <script src="js/jquery-1.4.4.min.js"></script>
    <script src="js/jquery.scianimator.min.js"></script>

<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3/highlight.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3/languages/r.min.js"></script>
<script>hljs.initHighlightingOnLoad();</script>
</head>
<body>
    <div class="scianimator"><div id="anim_plot" style="display: inline-block;"></div></div>
    <script src="js/anim_plot.js"></script>

<!-- highlight R code -->
</body>
</html>
<!--/html_preserve-->
Conclusion
----------

<br>

From the visualisation, you should be able to conclude whether or not your searches stay the same over time across the location you have specified. <br> <br>

In general, it has been found that users' most popular searches vary a lot in frequency over time and location.
