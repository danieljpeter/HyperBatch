# HyperBatch
A Hyper-Fast Batch Interface for Salesforce

# Why HyperBatch?

Simply put: speed! The traditional batchable interface in Apex can be too slow for some simple tasks. HyperBatch comes in to save you time.

### Comparison

Consider a scenario where we have 121.000 account records on the platform. We want to create 3 contacts for each account with a random "probability" field for each. 363.000 contacts in total. Then we update the highest and lowest probability on the account by querying the contacts. Get the overall highest and lowest probability across all accounts. Finally, we delete all of the contacts in the platform, and keep a running total of how many get deleted.

|Apex Job|Batchable|HyperBatch|Difference (minutes)|Percentage|
|---|---|---|---|---|
|CreateContactsBatch|45 minutes|2 minutes and 12 seconds|42.8|4.9%|
|UpdateContactsBatch|10 minutes|38 seconds|9.4|6.3%|
|DeleteContactsBatch|33 minutes (considering row lock errors)|1 minute and 11 seconds|28|3.6%|

Running all three sample batch jobs with HyperBatch takes only 4 minutes instead of 88 minutes! That means it only takes 4.6% of the time!

# But how it works?

Instead of handling everything to Apex and the server, HyperBatch orchestrates the batches on the browser. It still fires an AsyncApexJob, so it is possible for the tool to track the state of the job and act accordingly.

# Presentation (Slides and Video)

Presentation can be [found on SlideShare.net](http://www.slideshare.net/danieljpeter/hyperbatch-69179894) and there's a [presentation on YouTube, on the Salesforce Apex Hours channel](https://youtu.be/hja4o-Oa4zo?t=27m).
