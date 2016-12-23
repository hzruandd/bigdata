nohup bin/flume-ng agent --conf conf/ -f conf/taildir.conf
-Dflume.root.logger=INFO,console  --name demo-test >nohup.out 2>&1 &
nohup bin/flume-ng agent --conf conf/ -f conf/taildir_afa_to_2.11_kafka.conf
-Dflume.root.logger=debug,console  --name only211kafka >to_2.11_kafka.out 2>&1
&
nohup bin/flume-ng agent --conf conf/ -f conf/real/taildir_afe.conf
-Dflume.root.logger=INFO,console  --name real-demo-afe > real-demo-afe.out 2>&1
&
nohup bin/flume-ng agent --conf conf/ -f conf/real/taildir_afa.conf
-Dflume.root.logger=INFO,console  --name real-161220-afa >/dev/null 2>&1 &
nohup bin/flume-ng agent --conf conf/ -f conf/real/taildir_afe.conf
-Dflume.root.logger=INFO,console  --name real-161220-afe >/dev/null 2>&1 &
