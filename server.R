library(shiny)

  server = function(input, output,session) {
    data <- readRDS("testData.rds") 
    numberDataFrames <- length(data)
    labels <- list()
    for(i in 1:numberDataFrames){
      labels[[length(labels)+1]] <- rep(0,nrow(data[[i]]))
    }

    plotSize <- 400
    
    values <- reactiveValues()
    values$varIdx <- c(1,3)
    values$numberVars <- 2
    values$numVarIdx <- 1:4

    values$sliderLabelPosition <- 1
    values$dataFrameIdx <- 1
    values$labels <- labels
    values$numberRows <- nrow(data[[1]])
    values$varNames <- colnames(data[[1]])
    values$numVarNames <- colnames(data[[1]])
    
    observeEvent(input$reset, {
      values$varIdx <- c(1,3)
      values$numberVars <- 2
      values$numVarIdx <- 1:4
      
      values$sliderLabelPosition <- 1
      values$dataFrameIdx <- 1
      values$labels <- labels
      values$numberRows <- nrow(data[[1]])
      values$varNames <- colnames(data[[1]])
      values$numVarNames <- colnames(data[[1]])
      values$feedbackText <- "";

    })
    
    observeEvent(input$nextItem, {
      if(values$dataFrameIdx < numberDataFrames){
        values$dataFrameIdx <- values$dataFrameIdx+1
        values$numberRows <- nrow(data[[values$dataFrameIdx]])
        values$sliderLabelPosition <- 1
      }
    })
    
    observeEvent(input$prevItem, {
      if(values$dataFrameIdx >1){
        values$dataFrameIdx <- values$dataFrameIdx-1
        values$numberRows <- nrow(data[[values$dataFrameIdx]])
        values$sliderLabelPosition <- 1
      }
    })
    
    
    observeEvent(input$set_tag_label, {
      if(length(which(values$labels[[values$dataFrameIdx]]==1)) <2){
        values$labels[[values$dataFrameIdx]][input$tag_label] <- 1
        values$numberMarkersIncurrentRecording <- values$numberMarkersIncurrentRecording+1
      }
    })
    observeEvent(input$clear_tag_label, {
      values$labels[[values$dataFrameIdx]] <- 0
      values$numberMarkersIncurrentRecording <-0
    })
    output$slider_tag_label <- renderUI({
      sliderInput('tag_label', 'Interval border marker',min=1, max=values$numberRows, value=values$sliderLabelPosition,step=1, round=0)
    })
    
    observeEvent(input$key_press,{
      print(paste("key_press",input$key_press[1]))
      key_press <- input$key_press[1]
      if (is.null(key_press)) key_press <- 0
      # set label
      if (key_press == 13) {
        values$labels[[values$dataFrameIdx]][input$tag_label] <- 1
      }
      # next data set
      if (key_press == 35) {
        if(values$dataFrameIdx < numberDataFrames){
          values$dataFrameIdx <- values$dataFrameIdx+1
          values$numberRows <- nrow(data[[values$dataFrameIdx]])
          values$sliderLabelPosition <- 1
        }
      }
      # previous data set
      if (key_press == 43) {
        if(values$dataFrameIdx >1){
          values$dataFrameIdx <- values$dataFrameIdx-1
          values$numberRows <- nrow(data[[values$dataFrameIdx]])
          values$sliderLabelPosition <- 1
        }
      }
      # move 10 left
      if (key_press == 106) {
        if(values$sliderLabelPosition>10){
          values$sliderLabelPosition <- values$sliderLabelPosition-10
        }
      }
      # move 10 right
      if (key_press == 107) {
        if(values$sliderLabelPosition<values$numberRows-9){
          values$sliderLabelPosition <- values$sliderLabelPosition+10
        }
      }
      # move 1 left
      if (key_press == 110) {
        if(values$sliderLabelPosition>1){
          values$sliderLabelPosition <- values$sliderLabelPosition-1
        }
      }
      # move 1 right
      if (key_press == 109) {
        if(values$sliderLabelPosition<values$numberRows){
          values$sliderLabelPosition <- values$sliderLabelPosition+1
        }
      }
      })
    
    
    observeEvent(input$clear_vars, {
      values$varIdx <- NULL
      values$numberVars <- 0
      updateSelectInput(session, "varCols",selected="")
    })
    
    observeEvent(input$analyze_intervals, {
      numberIntervals <- 0
      sumIntervalSizes <- 0
      for(i in 1:numberDataFrames){
        labelIndex <- which(values$labels[[i]]==1)
        if(length(labelIndex)==2){
          numberIntervals <- numberIntervals+1
          intervalSize <- max(labelIndex) - min(labelIndex)
          sumIntervalSizes <- sumIntervalSizes + intervalSize
        }
      }

      if(numberIntervals>0){
        averageIntervalSize <- sumIntervalSizes/numberIntervals
        values$feedbackText <- paste("<b><font color='black'>Average interval size: ",as.character(averageIntervalSize) ,"</font></b>",sep="")
      }else{
        values$feedbackText <- paste("<b><font color='black'>No intervals have been marked yet...</font></b>",sep="")
      }
      
    })
    
    observeEvent(input$plot_vars, {
      allIdx <- c()
      for(i in input$varCols){
        idx <- which(values$varNames==i)
        allIdx <- c(allIdx,idx)
      }
      values$varIdx <- allIdx
      values$numberVars <- length(allIdx)
    })
    
    
    output$select_varCols <- renderUI({
      selectInput("varCols", "Click below to select time series:", values$numVarNames, selected=values$numVarNames[values$varIdx],multiple =TRUE,width=300)
    })
    
    output$feedback <- renderUI({
      HTML(paste("<b><font color='white'>",values$feedbackText,"</font></b>"))
    })
    
    output$itemNumber <- renderUI({
      if(values$dataFrameIdx>0){
HTML(paste("<b>Data recording number:<br><font color='green'>",values$dataFrameIdx,"/",as.character(numberDataFrames),"</font></b>"))
      }else{
HTML(paste("<b>Data recording number:<br><font color='green'></font></b>"))
      }
    })
    
    plotWidth <- function(){
      if(values$numberVars==0){
        return(1)
      }else{
       return(plotSize*values$numberVars) 
      }
      }
    
    output$plot <- renderPlot({values$dataFrameIdx
      if(is.null(data) || values$numberVars==0){
        return(NULL)
      }
      
      input$newplot
      tag_label <- input$tag_label
      X <- 1:values$numberRows
      
      tagIndex <- which(data[[values$dataFrameIdx]]$tag==1)
      labelIndex <- which(values$labels[[values$dataFrameIdx]]==1)
      
      par(mfrow=c(1,values$numberVars),mar=c(5,5,2,1))
      for(i in values$varIdx){
        Y <- data[[values$dataFrameIdx]][,i]
        plot(X,Y,pch='o',xlab="time step",ylab=names(data[[values$dataFrameIdx]])[i],cex.lab=2.0)
        abline(v=tag_label,col="green")

        for(j in labelIndex){
          abline(v=j,col="#337ab7",lty=2)
        }
        
        if(length(labelIndex)==2){
          polyX <- c(labelIndex[1],labelIndex[2],labelIndex[2],labelIndex[1])
          polyY <- c(0,0,max(Y),max(Y))
        polygon(polyX,polyY,col=rgb(0, 1, 0,0.1), border=NA)
        }
      }
      
    }
    , width = plotWidth, height = plotSize)

  }
