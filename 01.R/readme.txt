==================================
+         <= 文件结构说明 =>       +
==================================

======$$ 第一部分 总体质控 $$==================
├── 01.PCA1.pdf									                      两组差异PCA图；图中包括每个重复的信息等 比较全面有助于查询离群样品。
├── 01.PCA1.png									
├── 01.PCA_clean.pdf								                  两组差异PCA图；图中为干净的点，没有多于的信息，适合用AI修改后放文章中。
├── 01.PCA_clean.png			
├── 01.opls_da_result.pdf							                OPLS-DA结果; 主要看R2Y和Q2Y越接近与1说明模型越稳定，有的分析图中有类似PCA biplot的图，有的没有。不重要，主要是通过OPLS—DA得到VIP去判断差异
├── 01.opls_da_result.png
======$$ 第二部分 差异分析 $$==================
├── 02.All_compound_DAM_result.csv						        差异分析大表; 该表包含所有化合物做完差异分析的信息，包括了每个化合物中case、control的均值，log2fc，pvalue，qvalue，fdr， 表中化合物ID compoundID无重复，该表适合在不满意之前差异筛选阈值的条件下重新设定条件筛选差异代谢物。用excel的筛选选项卡即可。
├── 02.All_compound_DAM_result_annotation.csv					带化合物注释的差异分析大表；在差异分析大表的基础上把每个化合物的CD注释加了进来，这里化合物ID compoundID有重复
├── 03.DAM_compounds.csv							                **差异代谢物表；** 该表是阈值过滤后剩下的差异代谢物，该表中的化合物即为做完差异筛选后的化合物，compoundID无重复
├── 03.DAM_compounds_annot.csv							          **带注释的差异代谢物表；** 差异代谢物的基础上加入了每个化合物的注释，由于一个化合物可能匹配到多个pubchem CID，不同的pubchem CID对应的同分异构体在KEGG注释中不同，所以注释的时候保留了这些，所以该表中的compoundID有重复。
├── 03.DAM_upset.pdf								                  差异代谢物upsetplot；该图为在不同阈值条件下筛选出的差异代谢物个数，可以理解为venn，具体怎么看自行百度upset plot。
├── 03.DAM_upset.png
├── 04.volcano_plot.pdf								                **差异代谢物火山图；** 该图展示了设定阈值条件下差异代谢物在case/control间上下调的数量关系，红色代表上调，蓝色代表下调，灰色代表差异不显著，大小为VIP值。
├── 04.volcano_plot.png
├── 05.DAM_heatmap.pdf							                	**差异代谢物热图；** 该图包含了比较组合所有化合物，第一栏热图为根据行进行z-score的标准化峰面积，这样可以体现出同一化合物在不同sample直接的差异状态，但是不能体现实际的差异倍数及表达量高低，第二栏为峰面积整体做了log2标准化的热图，该图可以反应各个化合物的含量高低，但材料间的差异被弱化，第三栏到最后一栏分别为做差异分析使用的4个阈值，log2fc可以直观的看出材料间差异倍数变化，p值及FDR可以看出差异显著性，VIP也可以看出差异是否显著（越大越显著）
├── 05.DAM_heatmap.png
======$$ 第三部分 KEGG富集分析 $$==================
├── 06.KEGG_barplot.pdf								                **KEGG富集分析条形图；** 该图为差异代谢物根据提供的kegg背景文件做出的富集分析结果，x轴代表DAM中富集在对应通路中差异代谢物的个数，颜色代表富集显著性q-value值。
├── 06.KEGG_barplot.png
├── 06.KEGG_bubbleplot.pdf							              **KEGG富集分析气泡图；** 该图使用数据和条形图一致，只是可视化方式不同，展示的信息更多，x轴表示generaito，意思是DAM中富集在该通路的代谢物数量 / DAM代谢物总数，在超几何分布计算富集显著性中是一个重要指标，对应的还有bg_ratio.. 颜色代表负极显著性q-value, 大小代表DAM中富集在该通路的代谢物数量
├── 06.KEGG_bubbleplot.png
├── 07.KEGG_enrichment.csv							              **KEGG富集分析表；** 该表为富集分析结果，clusterProfiler直接导出。适合发表文章时以附表形式存在
├── 07.Pathway2Compound.csv						              	**KEGG富集分析表-代谢物展开：** 通路中的代谢物都集中在一个cell中，这里为了方便下面展开画图，对代谢物进行了展开匹配，将具体的信息融合进来，从该表可以直观的看到每个通路中都包含那些代谢物，这些代谢物的差异信息等。					
├── 08.KEGG_Enrichment_DAM_heatmap.pdf					      **KEGG富集通路-代谢物热图；** 根据上表将代谢物提取出来，制作了热图，由于一个代谢物可能对应多条通路，所以这里没法打标记，需要对应上表手动标记。
├── 08.KEGG_Enrichment_DAM_heatmap.png
======$$ 第四部分 KEGG通路分析 $$==================
├── 09.KEGG_Pathway_DAM_heatmap.pdf                   **KEGG代谢通路热图；** 该图相当于对富集分析的结果不设置阈值，统计差异代谢物参与调控的通路有哪些，这些显著性不具有意义。
├── 09.KEGG_Pathway_analysis_result.csv               **KEGG代谢通路分析表；** 该表为代谢通路分析结果，包含了所有可以匹配到的对应物种KEGG数据库上的通路。
├── 09.KEGG_Pathway_bar.pdf                           **KEGG代谢通路分析图；** 该图为通路分析条形图，和富集分析的一致。
├── 09.KEGG_pathway_DAM_heatmap.png                   
├── 09.Pathway2Compound_all.csv                       **KEGG代谢通路分析展开表；** 该表为上面通路分析表的展开，清楚的显示了每条通路对应的化合物。
======$$ 第五部分 plantcyc富集分析 $$==================
├── 10.DAM_plantcyc.csv                               **plantcycMS1数据过滤表；** 该表用差异代谢物的mw和mf去和plantcyc数据库进行匹配，mf一致，mw绝对值<5的被认为MS1信息匹配，匹配结果在该表中
├── 10.DAM_plantcyc_collapse.csv                      **plantcycMS1数据过滤收缩表；** 上表的基础上把compoundID唯一了，后续可以匹配到多个plantcyc的信息都放到了一个cell。
├── 10.DAM_plantcyc_enrichment.csv                    **plantcyc富集分析结果展开表；**
├── 10.DAM_plantcyc_enrichment.expand.csv             **plantcyc富集分析结果展开表；**
├── 10.DAM_plantcyc_enrichment_bar.pdf                **plantcyc富集分析条形图；**
├── 10.DAM_plantcyc_enrichment_bar.png                
├── 10.DAM_plantcyc_enrichment_bubble.pdf             **plantcyc富集分析气泡图；**
├── 10.DAM_plantcyc_enrichment_bubble.png
├── 11.PlantCyc_Enrichment_heatmap.pdf                **plantcyc富集分析热图；**
├── 11.PlantCyc_Enrichment_heatmap.png
======$$ 第六部分 plantcyc通路分析 $$==================
├── 12.DAM_plantcyc_Pathway.csv                       **plantcyc通路分析表；**
├── 12.DAM_plantcyc_Pathway.expand.csv                **plantcyc通路分析扩展表；**
├── 12.DAM_plantcyc_pathway_bar.pdf                   **plantcyc通路分析柱状图；**
├── 12.DAM_plantcyc_pathway_bar.png
├── 12.DAM_plantcyc_pathway_bubble.pdf                **plantcyc通路分析气泡图；**
├── 12.DAM_plantcyc_pathway_bubble.png
├── 12.PlantCyc_Pathway_heatmap.pdf                   **plantcyc通路分析热图；**
├── 12.PlantCyc_Pathway_heatmap.png
======$$ END $$==================

======$$ Summary $$==========
+  0 directories, 47 files  +
=============================

==================================
+          <= 常见问题 =>         +
==================================

======$$ 第一部分 总体质控 $$==================

Q1. PCA 杂乱无章，分辨不开
A1. 可能有两个原因，
    a). 首先可能是生物学重复不太好，组内差异较大，如果样本容量较大，剔除离群的样本重新做；
    b). 实验设计问题，可能你关注的差异来源并非两比较组主要的差异；
    c). 取材、做实验时样品弄混了...
Q2. OPLS-DA VIP是什么？ 有什么用：
A2. https://mp.weixin.qq.com/s/8glBnIfQAKDR8YUWRF6ZnA


======$$ 第二部分 差异分析 $$==================

Q1. 差异代谢物太少；
A1. 流程默认卡阈值是 `pvalue < 0.05 & VIP > 1` 已经是最宽松的阈值，报告中给出的差异代谢物数量已经是最多的。如果这样还是很少可能原因：
    a). 如果生物学重复很差，PCA就分不开，这里少是正常的，在t-test时组内较大的误差会导致pvalue普遍变大，尽管opls-da在一定程度上可以降低组内差异，但太离谱的话VIP值 > 1的代谢物肯定也会减少，有些误差是可以通过机器学习校正的，但是很大的误差没办法校正，如果没办法准备样品多做几个重复重新做吧；
    b). 如果生物学重复很好，PCA两组分界线也不是很明显，说明两个case/control两个材料确实差异不是很显著，差异代谢物少在某种程度上也是一个很好的结论；
    
Q2. 差异代谢物太多；
A2. a). 固定流程卡的阈值是最宽松的，一定程度上引入了假阳性结果，如果干扰了后续的分析，需要使用更严格的筛选条件，比如FDR及log2foldchange; 差异代谢物的筛选没有所谓的金标准，越松假阳性结果越多，越严格假阴性结果越多，个人意见先放一个宽松的阈值，结合后续的分析不断灵活调整参数，能解释自己的科学问题即可。
    b). 如果实验证据很充分，非靶做为补充结果说明建议卡比较严格的阈值，如果用作数据发掘，科学问题寻找，建议由松到紧，如果实验设计合理，非靶差异分析的结果应该是很稳健的。


======$$ 第三、四部分 KEGG富集、通路分析 $$==================

Q1. 富集结果通路太少，不聚焦；
A1. 富集分析的过程：
    a). CD搜库的结果和Pubchem比对过后得到InChIKey, 然后在CTS将InChIKey转换成KEGG的CompoundID，我们将对应物种的KEGG数据库从KEGG网站下载下来，构建TERM2COMPOUND和TERM2NAME数据集，使用clusterProfiler::enricher做富集分析；
    b). 所以最终呈现出来的富集分析结果受到CD搜库化合物名称准确性、InChIKey转换KEGG compoundID准确性以及对应物种是否存在该注释化合物参与的代谢通路的影响；
    通路少的原因：
    a). 如果差异的代谢物本来就少，而且CD注释的代谢物很可能无法注释到KEGG，那么最终的富集结果会很少，甚至没有。
    b). 有很多化合物可以注释到KEGG，但是有些可能在你选择的物种KEGG数据库没有收录相应的代谢通路（KEGG pathway不仅会考虑代谢物，更多的考虑是基因或者酶，这些有基因组的证据相对更稳健。）
    c). 有很多化合物可以注释到你物种的KEGG数据库，但根据超几何分布的算法，我们需要考虑两个ratio来计算富集的显著性，第一个较gene ratio(compound ratio),也就是你差异代谢物中，属于该通路的代谢物的数量/整体差异代谢物的数量，另外一个比值是background ratio, 该比值是差异代谢物中，属于该通路的代谢物的数量/该物种中属于该通路的代谢物数量。如果富集到该通路的化合物数量太少，那么他就显著。

Q2. 通路分析有啥用？
A2. MetaboAnalyst 提出通路拓扑分析的概念，我这里是伪通路分析，因为没有设计拓扑结构算法，目前没有搞清楚怎么通过分析层级结构定位通路重要性的算法实现。但他有下面的用处
    a). 其实可以理解为富集分析不卡阈值，这样，只有一个代谢物参与到该物种涉及的通路的结果也保留下来的。不考虑其显著性，这样可以从整体看这些差异代谢物都可能影响到了那些代谢通路。
    b). 由于非靶代谢定性和定量的不确定性，通路分析同样具有一定的参考价值。
    
======$$ 第五、六部分 plantcyc富集、通路分析 $$==================

Q1. 与KEGG有何区别；
A1. 仔细比对过拟南芥的KEGG和aracyc，发现aracyc更加全面，对通路的划分更加细致。而且网站交互性做的更好，通过这里的富集或者通路分析，我们很快可以用plantcyc网站的smart table找到通路中的酶，基因，更有利于多组学联合分析。

Q2. 富集结果好像没有KEGG多。
A2. 我猜测的原因：
    a).比如和KEGG同样的通路，由于plantcyc更加细致，参与注释同样的通路化合物更多，必然导致富集显著性分析时background ratio的下降，（差异的不一定增多，但背景一定增多），LC-MS能检测到的化合物种类和数量是一定的，但是背景文件是构建好的不变的。

    