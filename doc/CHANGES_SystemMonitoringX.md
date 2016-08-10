# Change log of SystemMonitoringX
* Copyright (C) 2006-2015 c.a.p.e. IT GmbH, http://www.cape-it.de/
* $Id$

# 5.0.1 (2015/03/02)
* (2016/03/02) - CR: T2015082690000581 (left one valid PostMaster::PreFilterModule on initial installation. This is needed to initially create necessary dynamic fields) (tlange)

# 5.0.0 (2015/03/01)
* (2016/03/01) - CR: T2015082690000581 (prepared $TicketObject->ArticleGet to get article dynamic field in unit test /SystemMonitoringX/scripts/test/SystemMonitoringX.t) (tlange)

# 4.99.83 (2015/02/20)
* (2016/02/19) - CR: T2015082690000581 (added allocation of Config- and MainObject in _GetDynamicFieldsDefinition in /var/packagesetup/SystemMonitoringX.pm) (tlange)
* (2016/02/19) - CR: T2015082690000581 (substantial code review and cleaning, added in unit test: DynamicFields => 1 in $TicketObject->TicketGet to include the dynamic field values) (tlange)
* (2016/01/22) - Bugfix: T2016011190001466 (used wrong SysConfig option) (tto)
* (2016/01/22) - Bugfix: T2016011190001466 (fixed module in SysConfig Ticket::EventModulePost###9-SystemMonitoringAcknowledgeX) (tto)

# 4.99.82 (2015/01/06)
* (2016/01/06) - CR: T2015082690000581 (added files from OTRS-package SystemMonitoring 5.0.1) (tlange)

# 4.99.81 (2015/10/20)
* (2015/10/20) - CR: T2015082690000581 (changed new and _GetDynamicFieldsDefinition in SystemMonitoringX.pm) (tlange)

# 4.99.80 (2015/09/10)
* (2015/09/10) - CR: T2015082690000581 (added framework 5.0) (tlange)

#4.0.1 (2015/0?/??)
 * (2015/06/16) - CR: T2015061590000354 (added 10 config options for postmaster filters) (tto)

#4.0.0 (2015/05/21)
 * (2015/04/28) - Bug: T2014121290000322 (correct wrong using of SysConfig-Values) (fober)
 * (2015/04/22) - CR: T2015031890000425 (added configuration that state is not updated if ticket is locked) (millinger)
 * (2015/04/22) - CR: T2015031890000425 (CREDITS: thanks to CANCOM GmbH for supporting this package) (millinger)
 * (2015/04/20) - Bugfix: T2015041790000372 (fix wrong sysconfig value for queue to create tickets) (fober)
 * (2015/04/10) - Bugfix: T2015040990000833 (fix missing object error) (fober)
 * (2015/04/08) - Bugfix: T201410139000048 (fixes for Framework 4.0) (fober)

#1.7.0 (2014/11/17)
 * (2014/11/17) - Bugfix: T2014090290000339 (TicketAutoLinkConfigItemlinked with any object in class if new CI-class definition or invalid attribute configured) (fober)
 * (2014/10/30) - CR: T2014101390000486 (changes for Framework 4.0) (fober) 

#1.6.1 (2014/10/13)
 * (2014/07/17) - Bugfix: T2014052190000499 ( wrong behaviour in TicketAutoLinkConfigItem ) (fober)

#1.6.0 (2014/02/18)
 * (2014/02/18) - CR: ( First productive release for OTRS 3.3 ) (fober)

#1.5.83 (2014/01/31)
 * (2014/01/31) - Bugfix: T2014012990000661 ( fix service alert - acknowledge ) (fober)

#1.5.82 (2014/01/13)
 * (2014/01/13) - CR: ( change code cause of additional needed perl libraries ) (fober)

#1.5.81 (2014/01/13)
#1.5.80 (2014/01/13)
 * (2014/01/13) - CR: (complete documentation, fix the handling of dynamic fields and the using of multible system momitoring tools ) (fober)

#1.5.0 (2013/04/??)
 * (2013/04/18) - CR: added changes from otrs 3.2.5 (ddoerffel)

#1.4.2 (2013/03/26)
 * (2013/03/26) - CR: added option to use free choice dynamic fields (rabo)
 * (2013/03/15) - Bugfix: no acknowledge send to nagios (rabo)

#1.4.1 (2012/08/27)
 * (2012/08/23) - Bugfix: SystemMonitoringAcknowledgeX.pm found no 'Fhost' (rabo)

#1.4.0 (2012/08/07)
 * (2012/08/07) - Bugfix: package-installation (rabo)

#1.4.0 (2012/08/07)
 * (2012/08/07) - CR: first release for OTRS 3.1 (rbo)
 * (2012/07/11) - Upgrade release for otrs 3.1.x, based on SystemMonitoring 2.3.1 (rabo)

#1.3.5 (2012/03/??)
 * (2012/03/14) - Bugfix:  TicketAutoLinkConfigItems extend search attributes (smehlig)

#1.3.4 (2011/08/24)
 * (2011/07/27) - Bugfix: added check for TimeObject in event TicketAutoLinkConfigItem (tto)

#1.3.3 (2011/07/06)
 * (2011/07/06) - Bugfix: error handling in PostMasterFilter (maba)

#1.3.2 (2011/07/01)
 * (2011/07/01) - CR: added option to define new ticket state (maba)
 * (2011/07/01) - CR: changed filenames of samples for better understanding (maba)

#1.3.1 (2011/04/01)
 * (2011/04/01) - Bugfix: unitializied parameter 
 * (2011/03/10) - CR: performance improvements for ticket-CI-link event 

#1.3.0 (2011/01/21)
 * (2011/01/21) - CR: init version for OTRS 3.0.x  

#1.2.3 (2010/10/27)
 * (2010/10/27) - CR: renamed default config entries for postmaster filter  

#1.2.2 (2010/07/05)
 * (2010/07/05) - CR: renamed PM-module registrations (four digits prefix)

#1.2.1 (2010/07/02)
 * (2010/07/02) - CR: changed identifier for OTRS Config placeholder
 * (2010/06/22) - CR: added option to register multiple system monitoring acknowledge
 * (2010/06/22) - CR: added enhancements for test-scripts
 * (2010/06/14) - CR: added changes from OTRS package "SystemMonitoring"
 * (2010/06/11) - CR: added option to register multiple system monitoring tools

#1.2.0 (2010/06/18)
 * (2010/06/17) - Bugfix: values set by match-db-filter for X-OTRS-Queue' && X-OTRS-Type' may override SysmonX-settings
 * (2010/06/16) - Bugfix: use own config instead of default values in SystemMonitoringX-Postmasterfilter
 * (2010/06/16) - CR: added option ToAddressRegExp to SystemMonitoringX-Postmasterfilter
 * (2010/06/16) - CR: new test mail files
 * (2010/06/11) - CR: added changes because of PerlCritic

#1.1.1 (2009/04/15)
 * (2010/03/01) - CR: added DefaultNagiosTicketType
 * (2009/10/30) - CR: added framework 2.4.x 

#1.1.0 (2009/10/29)
 * (2009/10/29) - CR: added TicketAutoLinkConfigItem functionality (newly created ticket may automatically be connected to CI from CMDB)

#1.0.1 (2009/06/23)
 * (2009/06/23) - Added usage of placeholder tags in SysConfig parameters
 * (2009/06/23) - changed location of ticket event NagiosAcknowledgeX

#1.0.0 (2009/02/09)
 * (2009/02/09) - First productive release, based on SystemMonitoring 2.0.3.
 * (2009/02/09) - extended Systemmonitoring config options: Address, Alias, Queue  
