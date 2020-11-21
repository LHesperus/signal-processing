## 阵列方向图/波束图
均匀线阵的方向图可以写成以下几种形式.
$F(\theta)=|w^{\rm{H}}a(\theta)|=|\sum_{n=0}^{N-1}{e^{-j\frac{2*\pi *d n}{\lambda}(\sin(\theta)-\sin(\theta_{0}))}}|= |\frac{\sin(N*\pi*d(\sin(\theta)-\sin(\theta_{0})))}{\sin(\pi*d(\sin(\theta)-\sin(\theta_{0})))}|$

$w$体现阵列属性
$\boldsymbol a(\theta)$是导向矢量,体现信号属性.
$ \boldsymbol a(\theta)s(n)$相当于各个阵列天线接收的信号,因为这些信号理论上只有相位差不同.

均匀线阵的特殊结构使波束图可以通过FFT求得
$|\sum_{n=0}^{N-1}{e^{-j\frac{2*\pi *d n}{\lambda}(\sin(\theta)-\sin(\theta_{0}))}}|$
即对$w$进行FFT变换,但要注意的是用FFT求得的数据,横坐标是sin(theta),需要换算成asin,才可以和正常的波束图对应上.


对于二维波束图(增加多普勒频率维),如机载信号处理中STAP,
二维的要对每个行和列分别做FFT变换.