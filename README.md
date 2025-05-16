# MGAM_CD
Unsupervised SAR Image Change Detection using Multi-level Graph Attribute Matching

# Introduction
Change detection between synthetic aperture radar (SAR) images is a topic of great interest yet fraught with challenges, primarily due to the complex contents and inherent speckle noises of SAR images. Promising change detection methods require the simultaneous extraction of discriminative features and the reduction of speckle noise interference to generate accurate change maps. To these ends, we proposed a novel SAR image change detection framework using multi-level graph attribute matching (MGAM). To elaborate further, the SAR images are first partitioned into a series of overlapping patches, which are embedded as features into the vertices. A novel global graph is constructed by connecting similar vertices throughout the entire image, with the edge weights derived from patch-based pairwise affinities. Through modelling global graphs on the two SAR images and mapping these graphs to one another, the change levels can be obtained by matching the attributes from vertices, edges, and subgraphs, thereby generating a difference image with good separability. Finally, change analysis is conducted using a binary classification algorithm.

# Citation
If you use this code for your research, please cite our paper. Thank you!
@ARTICLE{**, author={Jun Wang, Qiongjun Fu, Jiahui Li, Sanku Niu, Yaohui Zhu, Yuechao Zhang, and Pengle Cheng},
journal={International Journal of Remote Sensing},
title={Unsupervised SAR Image Change Detection using Multi-level Graph Attribute Matching},
year={2025}.}

# Running
Run the MGAM_CD demo files (tested in Matlab 2024b)!
If you have any queries, please contact me (36110@qzc.edu.cn).
