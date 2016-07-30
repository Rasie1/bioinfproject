q -H -d ";" "select pic
             from info_scorings.csv 
             where positive_tumor_cells = \"null\" or 
                   staining_intensity = \"null\" or 
                   ((slidemap = \"pko.hbn.1a.59\") and 
                     ((select Comments 
                       from info_samples.csv 
                       where SampleIDPREDECT = sample_predect) like '%ER neg%'))"

