library(shinythemes)

ui= shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  title = "Multiple Time Series Label Tool",
  
  tags$script('
    $(document).on("keypress", function (e) {
            
            Shiny.onInputChange("key_press", [e.which,e.timeStamp]);
            });
            '),

  
  sidebarLayout(
    

    
    # Sidebar
    sidebarPanel(
      
      HTML("
<b>Tl;dr:</b>
<br>
<i>This is a tool for a less painful manual labelling of multiple time series data.</i>

<br><br>
<b>How to use:</b>
<br>
 <ol>
  <li>Select one or several time series</li>
  <li>Plot the time series by pressing 'Plot selected'</li>
  <li>Set two markers:</li>
      - use slider to position the green line <br>
      - press 'Set marker' button to set a marker <br>
      - if necessary: use 'Clear markers' to clear markers in the current data recording<br>
  <li>Go to next data recording and repeat step 3. Do so until all recordings have been viewed</li>
  <li>Get statistics of the marked intervals by pressing 'Analyze marked intervals'</li>
</ol> 

<b>Purpose of this tool:</b>
<br>
Given are several recordings of multiple, simultaneous observed data streams.
During each recording a certain event occured.
This event causes anomalous values in our data streams over a short period of time.
We want to label this intervals in such a way that the data can be used to
train a binary classifier that is able to detect the event.
<br><br>
<i>A situation as described above might for example occur in IoT applications 
when the readings of multiple sensors are monitored over time to detect events in a system.</i>

<br><br>
<b>How the tool works:</b>
<br>
Often when looking at proper scaled time series plots, the deviation of the data can be spotted by a human observer quite easily.
<br><br>
<b>1.</b> Set markers for the interval borders in each recording. 
This is done by moving the slider to beginning and end of the interval in which we think the event happened. 
The plotted time series can freely be chosen among the existing predictors in our dataset.
We use the 'Set marker' button to save a marker at the current position.
The length of the intervals will vary among the different recordings.
Therefore the labelled intervals will not be comparable.
<br><br>
<b>2.</b> Now this tool automatically determines an optimal common interval length and shifts the saved markers accordingly.
<b>Because this is just a demo, this second step is not performed. Also uploading datasets and downloading resulting labelled data is not implemented. 
Instead a preloaded example dataset is used and results are cleared when hittig the 'Reset app' button.</b>
<br>

")
  
    ),
    
    # Main
    mainPanel(


      ########## Title
      fluidRow(
        column(12,
               align="center",
               HTML("<H1>Multiple Time Series Label Tool</H1>")
               )
      ),
      
      ########## Plots
      fluidRow(
        column(12,
               align="center",
               br(),
               plotOutput('plot', width = "100%")
               )
        ),
        
          ########## Control elements
          fluidRow(

            column(12,align="center",
                   htmlOutput("itemNumber"),
                   br(),
                   uiOutput("slider_tag_label"),
                   br(),
                   actionButton("prevItem", label = "< Previous recording"),
                   actionButton("set_tag_label", label = "Set marker", style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                   actionButton("clear_tag_label", label = "Clear markers"),
                   actionButton("nextItem", label = "Next recording >")

            )

            
          ),
          
          hr(),
          
          fluidRow(
            column(4,
                   align="right",
                   uiOutput("select_varCols")
            ),
            column(4,
                   align="left",
                   br(),
                   actionButton("plot_vars", label = "Plot selected"),
                   actionButton("clear_vars", label = "Clear plots"),
                   br(),br(),
                   HTML("<b>This is just a demo - only the average interval size is calculated and some features are not implemented!</b>"),
                   br(),
                   actionButton("analyze_intervals", label = "Analyze marked intervals", style="color: #fff; background-color: #ff7ab7; border-color: #2e6da4"),
                   br(),
                   HTML("<b>Results:</b>"),
                   br(),
                   htmlOutput("feedback")
            ),
            column(4,
                   align="left",
                   br(),br(),
                   actionButton("reset", label = "Reset app", style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
            )
          )
      
      
    ) # end main panel   
) # end sidebar layout
    
  )) # end fluid page
