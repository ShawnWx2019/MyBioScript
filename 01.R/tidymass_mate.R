
# load dependence ---------------------------------------------------------
suppressMessages(library(tidyverse))
suppressMessages(library(tidymass))
suppressMessages(library(PCAtools))
suppressMessages(library(plotly))
pacman::p_load(affy, parallel,ranger,caret,pcaMethods,ggplot2,tidyr,graphics,grDevices,Hmisc,gtools,cowplot,RColorBrewer,readr,plotly,stringr,GGally,dplyr,e1071,officer,bootstrap,pdist,metabolomics,data.table)


# Functions ----------------------------------------------------------------


#' 3D PCA with sample names
#' @param obj A massdataset. 
#' @param tag color tag of PCA plot 
#' @importFrom magrittr %>% 
#' @importFrom massdataset extract_expression_data 
#' @importFrom tibble as_tibble column_to_rownames
#' @importFrom PCAtools pca
#' @importFrom plotly plot_ly
#' @export
#' @return plt_pca a 3D pca
#' @example 
#' \dontrun{
#' Plt_3D_PCA(obj = object, tag = group)
#' }
Plt_3D_PCA = function(obj,tag,interactive = T) {
  tbl_for_pca <- 
    obj %>% 
    extract_expression_data()
  tbl_info <- 
    obj %>% 
    extract_sample_info() %>% 
    as_tibble() %>% 
    column_to_rownames('sample_id')

  obj_tbl <- PCAtools::pca(
    mat  = tbl_for_pca %>% select(rownames(tbl_info)),
    metadata = tbl_info,
    center = T,
    scale = T,
    removeVar = .1
  )
  if(isTRUE(interactive)) {
    plt_pca = plot_ly(
      x = obj_tbl$rotated$PC1,
      y = obj_tbl$rotated$PC2,
      z = obj_tbl$rotated$PC3,
      color = tbl_info %>% select(tag) %>% pull(tag),
      hovertext = rownames(tbl_info)
    )
  } else {
    plt_pca = biplot(
      pcaobj = obj_tbl,
      showLoadings = F,
      ellipse = T,ellipseAlpha = .2,
      lab = "",
      colby = tag,
      legendPosition = 'top',
    )
  }
  return(plt_pca)
}


#' rsd raw vs normalized.
#' @param obj_old A massdataset. raw data
#' @param obj_new A massdataset. normalized data 
#' @param x_loc Integer Position of lables on the x-axis.
#' @param x_loc Integer Position of lables on the y-axis.
#' @param norm_name 
#' @importFrom magrittr %>% 
#' @importFrom massdataset extract_expression_data 
#' @importFrom dplyr select group_by summarise mutate case_when inner_join
#' @importFrom  tibble rownames_to_column 
#' @importFrom PCAtools pca
#' @importFrom plotly plot_ly
#' @import ggplot
#' @importFrom  tidyr pivot_longer
#' @return rsd_plt a 3D pca
#' @example 
#' \dontrun{
#' Plt_3D_PCA(obj = object, tag = group)
#' }

plt_norm_rsd = function(obj_old,obj_new,x_loc = c(120,110),y_loc = c(15,110),norm_name = "svr"){
  # old rsd
  rsd_before <- 
    obj_old %>% 
    extract_expression_data() %>% 
    select(contains("QC")) %>% 
    rownames_to_column("ID") %>% 
    pivot_longer(contains("QC"),names_to = "tag",values_to = "value") %>% 
    select(-tag) %>% 
    group_by(ID) %>% 
    summarise(
      raw.rsd = (sd(value,na.rm = T)/mean(value,na.rm = T))*100
    )
  rsd_after <- 
    obj_new %>% 
    extract_expression_data() %>% 
    select(contains("QC")) %>% 
    rownames_to_column("ID") %>% 
    pivot_longer(contains("QC"),names_to = "tag",values_to = "value") %>% 
    select(-tag) %>% 
    group_by(ID) %>% 
    summarise(
      norm.rsd = (sd(value,na.rm = T)/mean(value,na.rm = T))*100
    )
  join_rsd <- inner_join(rsd_before,rsd_after,by = "ID") %>% 
    mutate(
      norm_tag = case_when(
        norm.rsd <= 30 ~ "RSD ≤ 30",
        TRUE ~ "RSD > 30 "
      ),
      raw_tag = case_when(
        raw.rsd <= 30 ~ "RSD ≤ 30",
        TRUE ~ "RSD > 30 "
      )
    )
  n1 = join_rsd %>% group_by(norm_tag) %>% summarise(num = n())
  
  rsd_plt = ggplot(data = join_rsd,mapping = aes(x = raw.rsd,y = norm.rsd,color = norm_tag)) +
    geom_point(size = 1.2,alpha =.8)+
    scale_color_manual(values = c("RSD ≤ 30" = "salmon","RSD > 30" = "grey30"))+
    geom_vline(xintercept = 30,linetype = "dashed",color = "red")+
    geom_hline(yintercept = 30,linetype = "dashed",color = "red")+
    geom_abline(slope = 1,linetype = "dashed",color = "red")+
    geom_label(
      data = data.frame(
        x = x_loc,
        y = y_loc,
        label = paste0("n=",c(n1[2,2],n1[1,2])),
        color = (c("RSD ≤ 30","RSD > 30"))
      ),
      mapping = aes(x = x,y = y,label = label,color= color),alpha = .8
    )+
    xlim(0,150)+
    ylim(0,150)+
    labs(x = "RSD of raw peak area",y = paste("RSD of", norm_name ,"normalized peak area"))+
    theme_bw()+
    theme(
      line = element_line(size = 2,color = "black"),
      rect = element_rect(size = 2, color = "black"),
      axis.text = element_text(size = 14, color = "black"),
      axis.title = element_text(size = 16,color = "black",face = "bold")
    )
  return(rsd_plt)
}


run_serrf = function(obj){
  
  expression_data <- 
    obj@expression_data %>% as.data.frame()
  group_info <- 
    obj@sample_info %>% 
    dplyr::mutate(
      label = sample_id,
      time = injection.order,
      sampleType = case_when(
        class == "QC" ~ "qc",
        TRUE ~ "sample"
      ),
      batch = "A"
    ) %>% 
    select(
      label,time,sampleType,batch
    )
  
  detectcores_ratio = 1
  # import data ------------------------------------------------------------
  
  p = group_info %>% as.data.table()
  
  # expression --------------------------------------------------------------
  
  e = as.matrix(expression_data)
  
  f = data.frame(
    label = rownames(expression_data),
    No = seq(1:nrow(expression_data))
  ) %>% 
    as.data.table()
  
  ## functions 
  remove_outlier = function(v){
    out = boxplot.stats(v)$out
    return(list(value = v[!v%in%out],index = which(v%in%out)))
  }
  loess_wrapper_extrapolate <- function (x, y, span.vals = seq(0.25, 1, by = 0.05), folds = 5){
    # Do model selection using mean absolute error, which is more robust than squared error.
    mean.abs.error <- numeric(length(span.vals))
    
    # Quantify error for each span, using CV
    loess.model <- function(x, y, span){
      loess(y ~ x, span = span, control=loess.control(surface="interpolate",statistics='exact'),family = "gaussian")
    }
    
    loess.predict <- function(fit, newdata) {
      predict(fit, newdata = newdata)
    }
    
    span.index <- 0
    
    for (each.span in span.vals) {
      span.index <- span.index + 1
      mean.abs.error[span.index] = tryCatch({
        y.hat.cv <- bootstrap::crossval(x, y, theta.fit = loess.model, theta.predict = loess.predict, span = each.span, ngroup = folds)$cv.fit
        non.empty.indices <- !is.na(y.hat.cv)
        diff = (y[non.empty.indices] / y.hat.cv[non.empty.indices]) * mean(y[non.empty.indices])
        sd(diff)/mean(diff)
      },error = function(er){
        NA
      })
    }
    best.span <- span.vals[which.min(mean.abs.error)]
    if(length(best.span)==0){
      best.span = 0.75
    }
    
    best.model <- loess(y ~ x, span = best.span, control=loess.control(surface="interpolate",statistics='exact'),family = "gaussian")
    
    return(list(best.model, min(mean.abs.error, na.rm = TRUE),best.span))
  }
  shiftData = function(ori,norm){
    ori.min = apply(ori,1,min,na.rm=T)
    norm.min = apply(norm,1,min,na.rm=T)
    return(norm - c(norm.min - ori.min))
  }
  RSD = function(data){
    return(apply(data,1,function(x){
      x = remove_outlier(x)[[1]]
      return(sd(x,na.rm=T)/mean(x,na.rm=T))
    }))
  }
  
  qc_RSDs = list()
  normalized_dataset = list()
  calculation_times = list()
  with_validate = any(!p$sampleType %in% c('qc','sample'))
  
  # split e, and p to different sample type.
  e_qc = e[, p$sampleType == 'qc']
  e_sample = e[, p$sampleType == 'sample']
  
  p_qc = p[p$sampleType == 'qc',]
  p_sample = p[p$sampleType == 'sample',]
  
  
  e_validates = list()
  
  p_validates = list()
  
  validate_types = NULL
  
  aggregate_e = function(e_qc,e_sample,e_validates){
    e = do.call('cbind',c(list(e_qc, e_sample), e_validates))
    e = e[,order(as.numeric(gsub("p","",colnames(e))))]
    return(e)
  }
  
  
  
  # start -------------------------------------------------------------------
  
  
  start = Sys.time()
  normalized_dataset[['none']] = aggregate_e(e_qc,e_sample,e_validates)
  qc_RSDs[['none']] = RSD(e_qc)
  calculation_times[['none']] = Sys.time() - start
  cat("<!--------- raw data --------->\n")
  cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['none']],na.rm = TRUE),4)*100,"%.\n"))
  cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['none']]<0.2,na.rm = TRUE),".\n"))
  
  normalized_dataset[['SERRF']] = tryCatch({
    cat("<!--------- SERRF --------->\n(This may take a while...)\n")
    
    e_norm = matrix(,nrow=nrow(e),ncol=ncol(e))
    QC.index = p[["sampleType"]]
    batch = p[["batch"]]
    time = p[["time"]]
    batch = factor(batch)
    num = 10
    start = Sys.time();
    
    cl = makeCluster(detectCores() * detectcores_ratio)
    
    # e_train = e_qc
    # e_target = e_validates[["Biorec"]]
    # num = 10
    # p_train = p_qc
    # p_target = p_validates[["Biorec"]]
    
    serrfR = function(train = e[,p$sampleType == 'qc'],
                      target = e[,p$sampleType == 'sample'],
                      num = 10,
                      batch. = factor(c(batch[p$sampleType=='qc'],batch[p$sampleType=='sample'])),
                      time. = c(time[p$sampleType=='qc'],time[p$sampleType=='sample']),
                      sampleType. = c(p$sampleType[p$sampleType=='qc'],p$sampleType[p$sampleType=='sample']),cl){
      
      
      all = cbind(train, target)
      normalized = rep(0, ncol(all))
      for(j in 1:nrow(all)){
        for(b in 1:length(unique(batch.))){
          current_batch = levels(batch.)[b]
          all[j,batch.%in%current_batch][all[j,batch.%in%current_batch] == 0] = rnorm(length(all[j,batch.%in%current_batch][all[j,batch.%in%current_batch] == 0]),mean = min(all[j,batch.%in%current_batch][!is.na(all[j,batch.%in%current_batch])])+1,sd = 0.1*(min(all[j,batch.%in%current_batch][!is.na(all[j,batch.%in%current_batch])])+.1))
          all[j,batch.%in%current_batch][is.na(all[j,batch.%in%current_batch])] = rnorm(length(all[j,batch.%in%current_batch][is.na(all[j,batch.%in%current_batch])]),mean = 0.5*min(all[j,batch.%in%current_batch][!is.na(all[j,batch.%in%current_batch])])+1,sd = 0.1*(min(all[j,batch.%in%current_batch][!is.na(all[j,batch.%in%current_batch])])+.1))
        }
      }
      
      corrs_train = list()
      corrs_target = list()
      for(b in 1:length(unique(batch.))){
        
        current_batch = levels(batch.)[b]
        
        train_scale = t(apply(train[,batch.[sampleType.=='qc']%in%current_batch],1,scale))
        if(is.null(target[,batch.[!sampleType.=='qc']%in%current_batch])){
          target_scale = t(apply(target[,batch.[!sampleType.=='qc']%in%current_batch],1,scale))
        }else{
          target_scale = scale(target[,batch.[!sampleType.=='qc']%in%current_batch])
        }
        
        # all_scale = cbind(train_scale, target_scale)
        
        # e_current_batch = all_scale
        corrs_train[[current_batch]] = cor(t(train_scale), method = "spearman")
        corrs_target[[current_batch]] = cor(t(target_scale), method = "spearman")
        # corrs[[current_batch]][is.na(corrs[[current_batch]])] = 0
      }
      
      
      
      
      pred = parSapply(cl, X = 1:nrow(all), function(j,all,batch.,ranger, sampleType., time., num,corrs_train,corrs_target){
        # for(j in 1:nrow(all)){
        # j = j+1
        print(j)
        normalized  = rep(0, ncol(all))
        qc_train_value = list()
        qc_predict_value = list()
        sample_value = list()
        sample_predict_value = list()
        
        for(b in 1:length(levels(batch.))){
          current_batch = levels(batch.)[b]
          e_current_batch = all[,batch.%in%current_batch]
          corr_train = corrs_train[[current_batch]]
          corr_target = corrs_target[[current_batch]]
          
          
          corr_train_order = order(abs(corr_train[,j]),decreasing = TRUE)
          corr_target_order = order(abs(corr_target[,j]),decreasing = TRUE)
          
          sel_var = c()
          l = num
          while(length(sel_var)<(num)){
            sel_var = intersect(corr_train_order[1:l], corr_target_order[1:l])
            sel_var = sel_var[!sel_var == j]
            l = l+1
          }
          
          
          
          train.index_current_batch = sampleType.[batch.%in%current_batch]
          train_data_y = scale(e_current_batch[j, train.index_current_batch=='qc'],scale=F)
          train_data_x = apply(e_current_batch[sel_var, train.index_current_batch=='qc'],1,scale)
          
          if(is.null(dim(e_current_batch[sel_var, !train.index_current_batch=='qc']))){
            test_data_x = t(scale(e_current_batch[sel_var, !train.index_current_batch=='qc']))
          }else{
            test_data_x = apply(e_current_batch[sel_var, !train.index_current_batch=='qc'],1,scale)
          }
          
          train_NA_index  = apply(train_data_x,2,function(x){
            sum(is.na(x))>0
          })
          
          train_data_x = train_data_x[,!train_NA_index]
          test_data_x = test_data_x[,!train_NA_index]
          
          if(!class(test_data_x)=="matrix"){
            test_data_x = t(test_data_x)
          }
          
          good_column = apply(train_data_x,2,function(x){sum(is.na(x))==0}) & apply(test_data_x,2,function(x){sum(is.na(x))==0})
          train_data_x = train_data_x[,good_column]
          test_data_x = test_data_x[,good_column]
          if(!class(test_data_x)=="matrix"){
            test_data_x = t(test_data_x)
          }
          train_data = data.frame(y = train_data_y,train_data_x )
          
          if(ncol(train_data)==1){# some samples have all QC constent.
            norm = e_current_batch[j,]
            normalized[batch.%in%current_batch] = norm
          }else{
            colnames(train_data) = c("y", paste0("V",1:(ncol(train_data)-1)))
            model = ranger(y~., data = train_data)
            
            test_data = data.frame(test_data_x)
            colnames(test_data) = colnames(train_data)[-1]
            
            norm = e_current_batch[j,]
            
            
            
            norm[train.index_current_batch=='qc'] = e_current_batch[j, train.index_current_batch=='qc']/((predict(model, data = train_data)$prediction+mean(e_current_batch[j,train.index_current_batch=='qc'],na.rm=TRUE))/mean(all[j,sampleType.=='qc'],na.rm=TRUE))
            # norm[!train.index_current_batch=='qc'] =(e_current_batch[j,!train.index_current_batch=='qc'])/((predict(model, data = test_data)$prediction + mean(e_current_batch[j,!train.index_current_batch=='qc'],na.rm=TRUE))/mean(e_current_batch[j,!train.index_current_batch=='qc'],na.rm=TRUE))
            
            norm[!train.index_current_batch=='qc'] =(e_current_batch[j,!train.index_current_batch=='qc'])/((predict(model,data = test_data)$predictions  + mean(e_current_batch[j, !train.index_current_batch=='qc'],na.rm=TRUE))/(median(all[j,!sampleType.=='qc'],na.rm = TRUE)))
            norm[!train.index_current_batch=='qc'][norm[!train.index_current_batch=='qc']<0]=e_current_batch[j,!train.index_current_batch=='qc'][norm[!train.index_current_batch=='qc']<0]
            
            
            # plot(p$time[batch.%in%b][!train.index_current_batch=='qc'], (e_current_batch[j,!train.index_current_batch=='qc'])/((predict(model,data = test_data)$predictions  + mean(e_current_batch[j, train.index_current_batch=='qc'],na.rm=TRUE))/(median(e_current_batch[j,!train.index_current_batch=='qc'],na.rm = TRUE))))
            
            
            norm[train.index_current_batch=='qc'] = norm[train.index_current_batch=='qc']/(median(norm[train.index_current_batch=='qc'],na.rm=TRUE)/median(all[j,sampleType.=='qc'],na.rm=TRUE))
            norm[!train.index_current_batch=='qc'] = norm[!train.index_current_batch=='qc']/(median(norm[!train.index_current_batch=='qc'],na.rm=TRUE)/median(all[j,!sampleType.=='qc'],na.rm=TRUE))
            norm[!is.finite(norm)] = rnorm(length(norm[!is.finite(norm)]),sd = sd(norm[is.finite(norm)],na.rm=TRUE)*0.01)
            
            
            
            
            out = boxplot.stats(norm, coef = 3)$out
            norm[!train.index_current_batch=='qc'][norm[!train.index_current_batch=='qc']%in%out] = ((e_current_batch[j,!train.index_current_batch=='qc'])-((predict(model,data = test_data)$predictions  + mean(e_current_batch[j, !train.index_current_batch=='qc'],na.rm=TRUE))-(median(all[j,!sampleType.=='qc'],na.rm = TRUE))))[norm[!train.index_current_batch=='qc']%in%out];
            norm[!train.index_current_batch=='qc'][norm[!train.index_current_batch=='qc']<0]=e_current_batch[j,!train.index_current_batch=='qc'][norm[!train.index_current_batch=='qc']<0]
            normalized[batch.%in%current_batch] = norm
            # points(current_time, norm, pch = (as.numeric(factor(train.index_current_batch))-1)*19, col = "blue", cex = 0.7)
            
            # qc_train_value[[b]] = train_data_y + mean(e_current_batch[j, train.index_current_batch=='qc'])
            # qc_predict_value[[b]] = predict(model,data = train_data)$predictions + mean(e_current_batch[j, train.index_current_batch=='qc'])
            # sample_value[[b]] = e_current_batch[j,!train.index_current_batch=='qc']
            # sample_predict_value[[b]] = predict(model,data = test_data)$predictions  + mean(e_current_batch[j, !train.index_current_batch=='qc'])
          }
          
          
          
          
          
          
        }
        
        
        # par(mfrow=c(1,2))
        # ylim = c(min(e[j,],norm), max(e[j,],norm))
        # plot(time.[sampleType.=='qc'], unlist(qc_train_value),col = "red",ylim = ylim,main=j)
        # points(time.[sampleType.=='qc'],unlist(qc_predict_value),col = "yellow")
        #
        # points(time.[!sampleType.=='qc'],unlist(sample_value),col = "blue")
        # points(time.[!sampleType.=='qc'],unlist(sample_predict_value),col = "green")
        #
        # plot(time.,normalized, col = factor(sampleType.), ylim = ylim,main=f$label[j])
        #
        # j = j + 1
        
        #
        
        
        
        # }
        
        
        
        
        return(normalized)
      },all,batch.,ranger, sampleType., time., num,corrs_train,corrs_target)
      
      
      
      
      normed = t(pred)
      
      normed_target = normed[,!sampleType.=='qc']
      
      
      for(i in 1:nrow(normed_target)){
        normed_target[i,is.na(normed_target[i,])] = rnorm(sum(is.na(normed_target[i,])), mean = min(normed_target[i,!is.na(normed_target[i,])], na.rm = TRUE), sd = sd(normed_target[i,!is.na(normed_target[i,])])*0.1)
      }
      for(i in 1:nrow(normed_target)){
        normed_target[i,normed_target[i,]<0] = runif(1) * min(normed_target[i,normed_target[i,]>0], na.rm = TRUE)
      }
      
      
      normed_train = normed[,sampleType.=='qc']
      
      
      for(i in 1:nrow(normed_train)){
        normed_train[i,is.na(normed_train[i,])] = rnorm(sum(is.na(normed_train[i,])), mean = min(normed_train[i,!is.na(normed_train[i,])], na.rm = TRUE), sd = sd(normed_train[i,!is.na(normed_train[i,])])*0.1)
      }
      for(i in 1:nrow(normed_train)){
        normed_train[i,normed_train[i,]<0] = runif(1) * min(normed_train[i,normed_train[i,]>0], na.rm = TRUE)
      }
      return(list(normed_train=normed_train,normed_target=normed_target))
    }
    
    
    serrf_normalized = e
    serrf_normalized_modeled = serrfR(train = e_qc, target = e_sample, num = num,batch. = factor(c(p_qc$batch, p_sample$batch)),time. = c(p_qc$time, p_sample$time),sampleType. = c(p_qc$sampleType, p_sample$sampleType),cl)
    
    serrf_qc = serrf_normalized_modeled$normed_train
    colnames(serrf_qc) = colnames(e_qc)
    serrf_sample = serrf_normalized_modeled$normed_target
    colnames(serrf_sample) = colnames(e_sample)
    
    serrf_cross_validated_qc = e_qc
    
    cv = 5
    RSDs = list()
    if(any(table(p_qc$batch))<7){
      ratio = 0.7
    }else{
      ratio = 0.8
    }
    
    test_indexes = split(1L:nrow(p_qc), c(1L:nrow(p_qc))%%cv)
    
    for(k in 1:cv){
      
      test_index = test_indexes[[k]]
      train_index = c(1L:nrow(p_qc))[-test_index]
      
      train_index = sample(1L:sum(p$sampleType=='qc'),round(sum(p$sampleType=='qc')*ratio))
      test_index = c(1L:sum(p$sampleType=='qc'))[!(c(1L:sum(p$sampleType=='qc'))%in%train_index)]
      
      
      while(length(unique(p_qc$batch[test_index]))<length(unique(batch))){
        train_index = sample(1L:nrow(p_qc),round(nrow(p_qc)*ratio))
        test_index = c(1L:nrow(p_qc))[!(c(1L:nrow(p_qc))%in%train_index)]
      }
      serrf_normalized_on_cross_validate = serrfR(train = e_qc[,train_index], target = e_qc[,test_index], num = num,batch. = factor(c(p_qc$batch[train_index],p_qc$batch[test_index])),time. = c(p_qc$time[train_index],p_qc$time[test_index]),sampleType. = rep(c("qc","sample"),c(length(train_index),length(test_index))),cl)
      
      serrf_cross_validated_qc[,test_index] = serrf_normalized_on_cross_validate$normed_target
      
      RSDs[[k]] = RSD(serrf_normalized_on_cross_validate$normed_target)
    }
    
    
    
    qc_RSD = apply(do.call("cbind",RSDs),1,mean)
    qc_RSDs[['SERRF']] = qc_RSD
    calculation_times[['SERRF']] = Sys.time() - start
    cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['SERRF']],na.rm = TRUE),4)*100,"%.\n"))
    cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['SERRF']]<0.2,na.rm = TRUE),".\n"))
    
    
    serrf_validates = list()
    if(with_validate){
      
      
      for(validate_type in validate_types){
        
        serrf_validates[[validate_type]] = serrfR(train = e_qc, target = e_validates[[validate_type]], num = num,batch. = factor(c(p_qc$batch, p_validates[[validate_type]]$batch)),time. = c(p_qc$time, p_validates[[validate_type]]$time),sampleType. = rep(c("qc","sample"),c(nrow(p_qc),nrow(p_validates[[validate_type]]))),cl)$normed_target
        
        colnames(serrf_validates[[validate_type]]) = colnames(e_validates[[validate_type]])
        
        val_RSDs[[validate_type]][['SERRF']] = RSD(serrf_validates[[validate_type]])
        cat(paste0("Average ",validate_type," RSD:",signif(median( val_RSDs[[validate_type]][['SERRF']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% ",validate_type," RSD:",sum( val_RSDs[[validate_type]][['SERRF']]<0.2,na.rm = TRUE),".\n"))
      }
      aggregate_e(serrf_qc,serrf_sample,serrf_validates)
    }else{
      aggregate_e(serrf_qc,serrf_sample,NULL)
    }
    
    
    
  }, error = function(error_message){
    error_message
  })
  rownames(normalized_dataset[['SERRF']]) = rownames(normalized_dataset[['none']])
  return(normalized_dataset)
}

