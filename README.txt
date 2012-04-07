soa-p provisioing

JA Bride

PURPOSE :   automate configuration, slimming and tuning of a Red Hat/JBoss SOA-Platform


DESIGN REQUIREMENTS :
    --  automate configuration of a SOA-P environment on RHEL 5.5 or RHEL 6
    --  using 'default' SOA-P configuration as a template, create a new SOA-P configuration: 'default-spp'
    --  remove all use of default Hypersonic database in SOA-Platform
    --  point SOA-P services requiring an RDBMS to a postgresql database
    --  automate configuration of mod_cluster functionality in the 'default-spp' configuration
    --  remove the following services from a SOA-P run-time
        -- ESB message store
        -- jbpm service
        -- JBoss Messaging
        -- spring service
