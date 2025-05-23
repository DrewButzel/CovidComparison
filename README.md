## CovidComparison Big Data Project
This project did very simple sentiment analysis comparing Reddit and Twitter sentiment towards Covid-19. Small and big data techniques were both used to demonstrate how much big data applications such as Spark speed up big data processing.
- **bash_scripts:** directory containing the small data bash scripts used for the small data analysis portion
- **sentiment_texts:** directory holding all the positive and negative words for all the languages we used
- **jupyter_notebooks**
  - *SparkClean:* removes newline characters from our datasets
  - *SparkProcessing:* performs the big data analysis portion
  - *TwitterLanguageAnalysis:* analyzes the languages to use for the Twitter data processing
  - *CleanDb:* creates the DuckDB databases used for small data processing
