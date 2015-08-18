# KaggleBikeShare
Code to Create GBM model. Top 5% Score.

![alt tag](https://github.com/frutoper/KaggleBikeShare/blob/master/bikes.png)

Kaggle hosts online data science competitions.  This competition asks participants to forecast city bikeshare usage in Washington D.C. given weather data. A summary of the competition can be found [HERE](https://www.kaggle.com/c/bike-sharing-demand).

Initially I was inspired by a blog post by [Brandon Harris](http://brandonharris.io/kaggle-bike-sharing/).
The main take aways were to consider time of day and weekday as factor variables.  These were constucted from datetime variable.
This model had a root mean squared logarithmic error of .49523

Efavdb is a cool data science blog.  They [shared code](http://efavdb.com/bike-share-forecasting/) in python and I converted it to R.  Three ideas came from this blog.  The first was to use GBM rather than Conditional Inference trees.  The second was to tune the hyper-parameters.  On future competitions I plan on spending even more time hyper-parameter tuning. The third idea was build seperate models for Regular and Casual users.
The python code had a listed RMSLE of .41969

My Final Public Leaderboard score was .37936. (111 out of 3252)
I used different hyper-parameters than Efavdb and included more data transforms to improve my score.
