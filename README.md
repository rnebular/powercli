# PowerCLI Scripting Nuggets

## DRS Rules

I didn't really reinvent any wheels here, but will say I had some trouble finding what I needed, all in one place anyhow. My use-case for this was the need to separate all of my Windows VM's to certain hosts in the cluster, and force them to stay there. This was needed for licensing reasons only, and had nothing to do with efficiency.

The script "UpdateOSVersionDRSrules.ps1" does the following:

1. This script assumes you are already connected to a VIServer. If you want, add a connect-viserver command to the start of the script for yourself.
2. It will prompt for the cluster to examine, and then inventory all VM's into two variable lists (windows and non-windows).
3. Next it will create two DRS VM Groups, named $clustername-windows and $clustername-linux (for the non-windows vm's).
4. Lastly, it will run the function created by LucD (linked below), and will add all VM's to one of the two DRS groups.

(http://www.lucd.info/2015/01/22/drsrule-drs-rules-and-groups-module/)

The goal after this would be to allow creation of Host groups, and eventually DRS rules that force my VM's to stay on the host group I defined. To try to keep things somewhat efficient, I eventually created:
A MUST rule to keep MS Windows VM's on a specific number of hosts.
SHOULD rule to keep most Linux VM's off those same hosts.

Sources to figure this all out:
http://www.van-lieshout.com/2011/06/drs-rules/
https://communities.vmware.com/message/1699823#1699823
http://www.lucd.info/2015/01/22/drsrule-drs-rules-and-groups-module/
https://raw.githubusercontent.com/PowerCLIGoodies/DRSRule/master/About_DRSRule.help.txt
