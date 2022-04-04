# cgroup内存压测
```
1、安装libcgroup-tools，并拷贝相关shell脚本至压测目录

2、测试内存，超出Limit会oom
set_memTest_to_cgroupV1Test.sh 

3、测试cpu
set_cpuTest_to_cgroupV1Test.sh

top查看进程消耗的cpu情况
参考：https://www.codeleading.com/article/11835560302/
```


