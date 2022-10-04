import sys
from pytools.pytools import execCmd

with open(sys.argv[1]) as f:
  txt=f.read()
lines=txt.splitlines()

seds=''
echos=''

for line in lines:
  echos+="echo '%s' >> /etc/firewall.user\n"%line
  seds+="sed -i '/%s/d' /etc/firewall.user\n"%(line.replace('/','\/') if not line == '' else '^\s*$')

genEcho=execCmd(echos.replace(' >> /etc/firewall.user',''))
if genEcho == txt+'\n':
  print('echo pass')
else:
  print('echo failed!')
  with open('/tmp/echo.txt','w') as f:
    f.write(genEcho)
  os.system('diff -up %s /tmp/echo.txt'%sys.argv[2])
  exit(1)
sedcmd=' | '.join(["echo '%s'"%txt]+[line.replace('-i ','').replace(' /etc/firewall.user','') for line in seds.splitlines()])
#print(sedcmd)
genSed=execCmd(sedcmd)
#print(genSed)
if genSed == '':
  print('sed pass')
else:
  print('sed failed!')
  exit(1)

with open(sys.argv[2]) as f:
  settingstxt=f.read()
  needsaved=settingstxt.replace('%firewall.user',seds+'\n'+echos,1)
with open(sys.argv[2],'w') as f:
  f.write(needsaved)

#print(seds)
#print(echos)
