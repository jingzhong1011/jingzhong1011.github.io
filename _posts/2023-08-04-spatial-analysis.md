---
title: 空間分析：繪圖與空間資訊處理
tags: 雜記
---

111-2學期地理系必修⟪空間分析⟫上課內容整理。
<!--more-->

---
## 空間資料處理

### 空間資料

在R當中，空間資料能夠以`sf`（Simple Feature for R）格式進行儲存，其分為兩部分資訊，分別代表「空間」及「屬性」。「屬性」為該資料框架（Data frame）之要素的屬性資訊，而「空間」則代表幾何資訊，由一個list組成，每一個`sfc`（Simple Feature Geometry List-column）儲存資料向量中所有的幾何資訊，每個元素都代表一個幾何元素，也就是`sfg`（Simple Feature Geometry）。


```R
library(sf)
# 讀入shp檔案
data <- st_read("data.shp", options = "ENCODING=BIG-5", quiet = T)
# 空間
data$geometry
st_geometry(data)
# 屬性
st_drop_geometry(data)
# 座標系統
st_crs(data)
# 面積
AREA <- st_area(data)
# 單位轉換（以面積為例）
set_units::set_units(AREA, km^2)
```
