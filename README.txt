soa-p provisioing

JA Bride

PURPOSE :   automate configuration, slimming & tuning of a JBoss SOA-Platform


DESIGN REQUIREMENTS :
    --  automate configuration of a SOA-P environment on RHEL 5.5 or RHEL 6
    --  using 'default' SOA-P runtime config as template, create: 'default-spp'
    --  remove all use of default Hypersonic database in SOA-Platform
    --  point SOA-P services requiring an RDBMS to a postgresql database
    --  automate configuration of mod_cluster functionality
    --  remove the following services from a SOA-P run-time
        -- ESB message store
        -- jbpm service
        -- JBoss Messaging
        -- spring service
