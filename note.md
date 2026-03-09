# Note Dorado
I found that dorado will always try to use httplib first and curl second, and httplib always failed. And seems dorado have to download both `rna004_130bps_sup@v5.3.0` and `rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1` to run. Modification model is weigh small than non-modification one.

```bash
(base) [vpm582@scarball06fl ~]$ dorado basecaller rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 /projects/renlab/data/projects/projects_with_PB/AMV/nanopore_data/CONTROL_COLD_COL0MOCK/*/*/pod5 \
>         -x 'cuda:0,1,2' > basecall_output_dir/CONTROL_COLD_COL0MOCK.bam
[2026-03-09 22:45:32.315] [info] Running: "basecaller" "rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1" "/projects/renlab/data/projects/projects_with_PB/AMV/nanopore_data/CONTROL_COLD_COL0MOCK/CONTROL_COLD_COL0MOCK/20241129_0034_MN43552_FAZ56545_481633df/pod5" "-x" "cuda:0,1,2"
[2026-03-09 22:45:32.402] [warning] Unknown certs location for current distribution. If you hit download issues, use the envvar `SSL_CERT_FILE` to specify the location manually.
[2026-03-09 22:45:32.404] [info]  - downloading rna004_130bps_sup@v5.3.0 with httplib
[2026-03-09 22:45:32.415] [error] Failed to download rna004_130bps_sup@v5.3.0: SSL server verification failed
[2026-03-09 22:45:32.415] [info]  - downloading rna004_130bps_sup@v5.3.0 with curl
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
100 178.3M 100 178.3M   0      0 88.09M      0   00:02   00:02         76.48M
[2026-03-09 22:45:40.987] [warning] Unknown certs location for current distribution. If you hit download issues, use the envvar `SSL_CERT_FILE` to specify the location manually.
[2026-03-09 22:45:40.987] [info]  - downloading rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 with httplib
[2026-03-09 22:45:40.997] [error] Failed to download rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1: SSL server verification failed
[2026-03-09 22:45:40.997] [info]  - downloading rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 with curl
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
100 11.29M 100 11.29M   0      0 141.4M      0                              0
[2026-03-09 22:45:41.964] [info]  - BAM format does not support `U`, so RNA output files will include `T` instead of `U` for all file types.
[2026-03-09 22:45:41.973] [info] > Creating basecall pipeline
[2026-03-09 22:45:47.948] [info] Using CUDA devices:
[2026-03-09 22:45:47.948] [info] cuda:0 - NVIDIA H100 NVL
[2026-03-09 22:45:47.948] [info] cuda:1 - NVIDIA H100 NVL
[2026-03-09 22:45:47.948] [info] cuda:2 - NVIDIA H100 NVL
^C
(base) [vpm582@scarball06fl ~]$ dorado basecaller rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 /projects/renlab/data/projects/projects_with_PB/AMV/nanopore_data/CONTROL_COLD_COL0MOCK/*/*/pod5         -x 'cuda:0,1,2' > basecall_output_dir/CONTROL_COLD_COL0MOCK.bam
[2026-03-09 22:46:01.192] [info] Running: "basecaller" "rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1" "/projects/renlab/data/projects/projects_with_PB/AMV/nanopore_data/CONTROL_COLD_COL0MOCK/CONTROL_COLD_COL0MOCK/20241129_0034_MN43552_FAZ56545_481633df/pod5" "-x" "cuda:0,1,2"
[2026-03-09 22:46:01.266] [warning] Unknown certs location for current distribution. If you hit download issues, use the envvar `SSL_CERT_FILE` to specify the location manually.
[2026-03-09 22:46:01.267] [info]  - downloading rna004_130bps_sup@v5.3.0 with httplib
[2026-03-09 22:46:01.293] [error] Failed to download rna004_130bps_sup@v5.3.0: SSL server verification failed
[2026-03-09 22:46:01.293] [info]  - downloading rna004_130bps_sup@v5.3.0 with curl
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
100 178.3M 100 178.3M   0      0 226.0M      0                              0
[2026-03-09 22:46:08.433] [warning] Unknown certs location for current distribution. If you hit download issues, use the envvar `SSL_CERT_FILE` to specify the location manually.
[2026-03-09 22:46:08.434] [info]  - downloading rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 with httplib
[2026-03-09 22:46:08.442] [error] Failed to download rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1: SSL server verification failed
[2026-03-09 22:46:08.442] [info]  - downloading rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 with curl
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
100 11.29M 100 11.29M   0      0 154.0M      0                              0
[2026-03-09 22:46:08.995] [info]  - BAM format does not support `U`, so RNA output files will include `T` instead of `U` for all file types.
[2026-03-09 22:46:09.005] [info] > Creating basecall pipeline
[2026-03-09 22:46:10.079] [info] Using CUDA devices:
[2026-03-09 22:46:10.079] [info] cuda:0 - NVIDIA H100 NVL
[2026-03-09 22:46:10.079] [info] cuda:1 - NVIDIA H100 NVL
[2026-03-09 22:46:10.079] [info] cuda:2 - NVIDIA H100 NVL
[2026-03-09 22:46:14.702] [info] Calculating optimized batch size for GPU "NVIDIA H100 NVL" and model rna004_130bps_sup@v5.3.0. Full benchmarking will run for this device, which may take some time.
[2026-03-09 22:46:14.752] [info] Calculating optimized batch size for GPU "NVIDIA H100 NVL" and model rna004_130bps_sup@v5.3.0. Full benchmarking will run for this device, which may take some time.
[2026-03-09 22:46:14.758] [info] Calculating optimized batch size for GPU "NVIDIA H100 NVL" and model rna004_130bps_sup@v5.3.0. Full benchmarking will run for this device, which may take some time.
[2026-03-09 22:46:15.613] [info] cuda:0 using chunk size 18432, batch size 96
[2026-03-09 22:46:15.712] [info] cuda:0 using chunk size 9216, batch size 96
[2026-03-09 22:46:18.687] [info] cuda:1 using chunk size 18432, batch size 416
[2026-03-09 22:46:18.687] [info] cuda:2 using chunk size 18432, batch size 288
[2026-03-09 22:46:18.938] [info] cuda:2 using chunk size 9216, batch size 800
[2026-03-09 22:46:19.026] [info] cuda:1 using chunk size 9216, batch size 800
[███████████▎                  ] 37% [04m:26s<07m:17s] Basecalling    
```
