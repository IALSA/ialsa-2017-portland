This is the designated location for placing model output files. 


Physical-Cognitive stream
===


The files with `.out` extension, containing the text out put with model results, are available online, in the folder `studies`. However `.dat` and `.gh5` files are stored in a separate archive. Please follow the [link][shared-location-phys-cog] to download.


While all models are estimated in Mplus, some of them used the help of R wrapper scripts, that mechanized model specification and estimation processes. Regardless of the orgin, all models (`.out` files) are treated by a sequence of R scripts that parse, clean, and prepare a stream's `___catalog___` - a data set organizing model results in a shape convenient for subsequent production of table, graphs, and other analytical products.

|Mechanized   |Manual|
|---|---|
|LASA   |EAS   |
|MAP   |ELSA   |
|OCTO   |HRS   |
|   |ILSE   |
|   |NuAge   |
|   |SATSA   |
|_Mechanized estimation_  |_Catalog assembly_   |
|![][workflow-estimation] |![][workflow-catalog]  |



[workflow-estimation]:https://github.com/IALSA/ialsa-2017-portland/blob/master/libs/images/work-flow-diagram-auto-estimation.jpg?raw=true
[workflow-catalog]:https://github.com/IALSA/ialsa-2017-portland/blob/master/libs/images/work-flow-diagram-catalog-assembly.jpg?raw=true
[shared-location-phys-cog]: