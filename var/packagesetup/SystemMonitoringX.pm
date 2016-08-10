# --
# SystemMonitoringX.pm - code to excecute during package installation
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# Extensions Copyright (C) 2006-2015 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Ralf(dot)Boehm(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Frank(dot)Oberender(at)cape(dash)it(dot)de
# * Thomas(dot)Lange(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::SystemMonitoringX;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::SysConfig',
    'Kernel::System::Valid',
    'Kernel::System::DynamicField',
    'Kernel::System::Log',
    'Kernel::System::Main',
);

=head1 NAME

SystemMonitoringX.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $CodeObject = $Kernel::OM->Get('var::packagesetup::SystemMonitoringX');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );
    $Self->{ConfigObject}       = $Kernel::OM->Get('Kernel::Config');
    $Self->{SysConfigObject}    = $Kernel::OM->Get('Kernel::System::SysConfig');
    $Self->{ValidObject}        = $Kernel::OM->Get('Kernel::System::Valid');
    $Self->{DynamicFieldObject} = $Kernel::OM->Get('Kernel::System::DynamicField');
    $Self->{LogObject}          = $Kernel::OM->Get('Kernel::System::Log');
    $Self->{MainObject}         = $Kernel::OM->Get('Kernel::System::Main');
    $Self->{TypeObject}         = $Kernel::OM->Get('Kernel::System::Type');

    # rebuild ZZZ* files
    $Self->{SysConfigObject}->WriteDefault();

    # define the ZZZ files
    my @ZZZFiles = (
        'ZZZAAuto.pm',
        'ZZZAuto.pm',
    );

    # reload the ZZZ files (mod_perl workaround)
    for my $ZZZFile (@ZZZFiles) {

        PREFIX:
        for my $Prefix (@INC) {
            my $File = $Prefix . '/Kernel/Config/Files/' . $ZZZFile;
            next PREFIX if !-f $File;

            do $File;
            last PREFIX;
        }
    }

    # always discard the config object before package code is executed,
    # to make sure that the config object will be created newly.
    # Thus it will use the recently written new config from the package
    $Kernel::OM->ObjectsDiscard(
        Objects => ['Kernel::Config'],
    );

    # define file prefix
    $Self->{FilePrefix} = 'SystemMonitoring';

    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    # create needed types and states
    $Self->_CreateTicketTypes();
    $Self->_CreateDynamicFields();
    return 1;
}

=item CodeReinstall()

run the code reinstall part

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;

    # create needed types and states
    $Self->_CreateTicketTypes();
    $Self->_CreateDynamicFields();

    return 1;
}

=item CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    $Self->_CreateDynamicFields();
    $Self->_UpgradeOldSystemMonitoringPostmasterFilters();

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    return 1;
}

=item _AddSysConfigValue()

add SysConfigValue for Hash and Arrays

    my $Result = $CodeObject->_AddSysConfigValue(
        Name  => 'Tool::Acknowledge::DynamicField::Host1'
        Key   => 'xyz' # only vor Hashes
        Value => '123'
    );

=cut

sub _CreateTicketTypes {
    my ( $Self, %Param ) = @_;

    my %Validlist = $Self->{ValidObject}->ValidList();
    my %TmpHash2  = reverse(%Validlist);
    $Self->{ReverseValidList} = \%TmpHash2;
    $Self->{ValidList}        = \%Validlist;
    
    # define new ticket types 
    my %TicketTypes = (
        'Incident' => 1,
    );

    if ( %TicketTypes ) {

        # refresh type list due to possible changes
        my %TicketTypeList = $Self->{TypeObject}->TypeList( Valid => 0 );
        my %TicketTypeListReverse = reverse %TicketTypeList;

        # enabled/create ticket types...
        for my $Type ( keys %TicketTypes ) {
            next if !$TicketTypes{$Type};
            # enable existing ticket type...
            if ( $TicketTypeListReverse{$Type} ) {
                $Self->{TypeObject}->TypeUpdate(
                    Name    => $Type,
                    ID      => $TicketTypeListReverse{$Type},
                    ValidID => $Self->{ReverseValidList}->{valid},
                    UserID  => 1,
                );
            }

            # create new ticket type...
            else {
                $Self->{TypeObject}->TypeAdd(
                    Name    => $Type,
                    ValidID => $Self->{ReverseValidList}->{valid},
                    UserID  => 1,
                );
            }
        }
    }
    return 1;
}

sub _AddSysConfigValue {
    my ( $Self, %Param ) = @_;

    return if ( !$Param{Name} );

    my $SysConfigVal = '';
    if ( $Param{Name} =~ /###/ ) {
        my @SysConfigObject = split( /###/, $Param{Name} );
        my $SysConfigObj = $Self->{ConfigObject}->Get( $SysConfigObject[0] );

        # if second element (which is the name) of $SysConfigObject is filled, get it
        if ( $SysConfigObj && ref($SysConfigObj) && $SysConfigObj->{ $SysConfigObject[1] } ) {
            $SysConfigVal = $SysConfigObj->{ $SysConfigObject[1] };
        }
    }
    else {
        $SysConfigVal = $Self->{ConfigObject}->Get( $Param{Name} );
    }

    return if ( !$SysConfigVal );

    # check config-object
    my $ObjectType = ref($SysConfigVal) || '';

    return if ( !$ObjectType && ( $ObjectType ne 'HASH' && $ObjectType ne 'ARRAY' ) );
    return if ( $ObjectType eq 'HASH' && ( !$Param{Key} || !defined( $Param{Value} ) ) );
    return if ( $ObjectType eq 'ARRAY' && !$Param{Value} );

    if ( $ObjectType eq 'HASH' ) {
        $SysConfigVal->{ $Param{Key} } = $Param{Value};
    }
    elsif ( $ObjectType eq 'ARRAY' ) {
        push( @{$SysConfigVal}, $Param{Value} );
    }

    my $Result = $Self->{SysConfigObject}->ConfigItemUpdate(
        Valid => 1,
        Key   => $Param{Name},
        Value => $SysConfigVal,
    );

    return 1;
}

=item _DelSysConfigValue()

deletes SysConfigValue for Hash and Arrays

    my $Result = $CodeObject->_AddSysConfigValue(
        Name  => 'Tool::Acknowledge::DynamicField::Host1'
        Key   => 'xyz' # only vor Hashes
    );

=cut

sub _DelSysConfigValue {
    my ( $Self, %Param ) = @_;

    return if ( !$Param{Name} );

    my $SysConfigVal = '';
    if ( $Param{Name} =~ /###/ ) {
        my @SysConfigObject = split( /###/, $Param{Name} );
        my $SysConfigObj = $Self->{ConfigObject}->Get( $SysConfigObject[0] );
        if ( $SysConfigObj && ref($SysConfigObj) && $SysConfigObj->{ $SysConfigObject[1] } ) {
            $SysConfigVal = $SysConfigObj->{ $SysConfigObject[1] };
        }
    }
    else {
        $SysConfigVal = $Self->{ConfigObject}->Get( $Param{Name} );
    }

    return if ( !$SysConfigVal );

    my $ObjectType = ref($SysConfigVal) || '';

    return if ( !$ObjectType && $ObjectType ne 'HASH' );
    return if ( $ObjectType eq 'HASH' && !$Param{Key} );

    if ( $ObjectType eq 'HASH' && $SysConfigVal->{ $Param{Key} } ) {
        delete $SysConfigVal->{ $Param{Key} };
    }

    my $Result = $Self->{SysConfigObject}->ConfigItemUpdate(
        Valid => 1,
        Key   => $Param{Name},
        Value => $SysConfigVal,
    );

    return 1;
}

sub _UpgradeOldSystemMonitoringPostmasterFilters {
    my ( $Self, %Param ) = @_;

    # get all SystemMonitoring-PostmasterFilters
    my @SystemMonitoringKeys = (
        'AcknowledgeName',
        'AddressRegExp',
        'AliasRegExp',
        'ArticleType',
        'CloseActionState',
        'ClosePendingTime',
        'CloseTicketRegExp',
        'DefaultService',
        'DynamicFieldContent::Article',
        'DynamicFieldContent::Ticket',
        'DynamicFieldAddress',
        'DynamicFieldAlias',
        'DynamicFieldHost',
        'DynamicFieldService',
        'DynamicFieldState',
        'FromAddressRegExp',
        'HostRegExp',
        'Module',
        'NewTicketRegExp',
        'OTRSCreateTicketQueue',
        'OTRSCreateTicketSLA',
        'OTRSCreateTicketService',
        'OTRSCreateTicketState',
        'OTRSCreateTicketType',
        'OTRSCreateSenderType',
        'OTRSCreateArticleType',
        'ServiceRegExp',
        'StateRegExp',
        'StopAfterMatch',
        'ToAddressRegExp'
    );
    my $PostMasterFilters = $Self->{ConfigObject}->Get("PostMaster::PreFilterModule");
    if ( $PostMasterFilters && ref($PostMasterFilters) eq 'HASH' ) {
        for my $HashKey ( keys %{$PostMasterFilters} ) {
            next if ( $HashKey !~ /SystemMonitoring/ );
            next
                if (
                !$PostMasterFilters->{$HashKey}
                && ref( $PostMasterFilters->{$HashKey} ) ne 'HASH'
                );

    # delete old values with FreeTextFieldContents - since OTRS 3, we use contents of Dynamic Fields
            $Self->_DelSysConfigValue(
                Name => 'PostMaster::PreFilterModule###' . $HashKey,
                Key  => 'FreeTextFieldContents',
            );

            # if config-keys doesn't exist yet, create them
            for my $SystemMonitoringKey (@SystemMonitoringKeys) {
                next if ( $PostMasterFilters->{$HashKey}->{$SystemMonitoringKey} );

                if ( $SystemMonitoringKey eq 'DynamicFieldContent::Article' ) {
                    $Self->_AddSysConfigValue(
                        Name  => 'PostMaster::PreFilterModule###' . $HashKey,
                        Key   => $SystemMonitoringKey,
                        Value => $PostMasterFilters->{$HashKey}->{$SystemMonitoringKey} || 'State',
                    );
                }
                elsif ( $SystemMonitoringKey eq 'DynamicFieldContent::Ticket' ) {
                    $Self->_AddSysConfigValue(
                        Name  => 'PostMaster::PreFilterModule###' . $HashKey,
                        Key   => $SystemMonitoringKey,
                        Value => $PostMasterFilters->{$HashKey}->{$SystemMonitoringKey}
                            || 'Host,Service,Address,Alias',
                    );
                }
                elsif ( $SystemMonitoringKey eq 'OTRSCreateTicketQueue' ) {
                    $Self->_AddSysConfigValue(
                        Name  => 'PostMaster::PreFilterModule###' . $HashKey,
                        Key   => $SystemMonitoringKey,
                        Value => $PostMasterFilters->{$HashKey}->{$SystemMonitoringKey}
                            || $PostMasterFilters->{$HashKey}->{'Queue'}
                            || '',
                    );
                    $Self->_DelSysConfigValue(
                        Name => 'PostMaster::PreFilterModule###' . $HashKey,
                        Key  => 'Queue',
                    );
                }
                elsif ( $SystemMonitoringKey eq 'OTRSCreateTicketType' ) {
                    $Self->_AddSysConfigValue(
                        Name  => 'PostMaster::PreFilterModule###' . $HashKey,
                        Key   => $SystemMonitoringKey,
                        Value => $PostMasterFilters->{$HashKey}->{$SystemMonitoringKey}
                            || $PostMasterFilters->{$HashKey}->{'DefaultNagiosTicketType'}
                            || '',
                    );
                    $Self->_DelSysConfigValue(
                        Name => 'PostMaster::PreFilterModule###' . $HashKey,
                        Key  => 'DefaultNagiosTicketType',
                    );
                }
                elsif ( $SystemMonitoringKey eq 'StopAfterMatch' ) {
                    $Self->_AddSysConfigValue(
                        Name  => 'PostMaster::PreFilterModule###' . $HashKey,
                        Key   => $SystemMonitoringKey,
                        Value => $PostMasterFilters->{$HashKey}->{$SystemMonitoringKey} || '1',
                    );
                }
                else {
                    $Self->_AddSysConfigValue(
                        Name  => 'PostMaster::PreFilterModule###' . $HashKey,
                        Key   => $SystemMonitoringKey,
                        Value => $PostMasterFilters->{$HashKey}->{$SystemMonitoringKey} || '',
                    );
                }
            }
        }
    }

    return 1;
}

=item _CreateDynamicFields()

creates all dynamic fields that are necessary for SystemMonitoringX

    my $Result = $CodeObject->_CreateDynamicFields();

=cut

sub _CreateDynamicFields {
    my ( $Self, %Param ) = @_;
    my $ValidID = $Self->{ValidObject}->ValidLookup(
        Valid => 'valid',
    );

    # get dynamic field object
    my $DynamicFieldObject = $Self->{DynamicFieldObject};

    # get all current dynamic fields
    my $DynamicFieldList = $DynamicFieldObject->DynamicFieldListGet(
        Valid => 0,
    );

    # get the list of order numbers (is already sorted).
    my @DynamicfieldOrderList;
    for my $Dynamicfield ( @{$DynamicFieldList} ) {
        push @DynamicfieldOrderList, $Dynamicfield->{FieldOrder};
    }
    # get the last element from the order list and add 1
    my $NextOrderNumber = 1;
    if (@DynamicfieldOrderList) {
        $NextOrderNumber = $DynamicfieldOrderList[-1] + 1;
    }
    # get the definition for all dynamic fields for
    my @DynamicFields = $Self->_GetDynamicFieldsDefinition();

    # create dynamic fields
    DYNAMICFIELD:
    for my $DynamicField (@DynamicFields) {

        # create a new field
        my $OldDynamicField = $DynamicFieldObject->DynamicFieldGet(
            Name => $DynamicField->{Name},
        );

        if ( defined($OldDynamicField) ) {
            if ( exists( $OldDynamicField->{Label} ) ) {
                if (
                    ( $OldDynamicField->{Label} eq $DynamicField->{Label} )
                    )
                {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'info',
                        Message  => "Field already exists Label:$DynamicField->{Label}, skipping."
                    );
                    next DYNAMICFIELD;    # skip the record, it has been created already
                }
            }
        }

        my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
            Name       => $DynamicField->{Name},
            Label      => $DynamicField->{Label},
            FieldOrder => $NextOrderNumber,
            FieldType  => $DynamicField->{FieldType},
            ObjectType => $DynamicField->{ObjectType},
            Config     => $DynamicField->{Config},
            ValidID    => $ValidID,
            UserID     => 1,
        );
        next DYNAMICFIELD if !$FieldID;

        # increase the order number
        $NextOrderNumber++;

    }

    return 1;
}

=item _GetDynamicFieldsDefinition()

returns the definition for System MonitoringX related dynamic fields

    my $Result = $CodeObject->_GetDynamicFieldsDefinition();

=cut

sub _GetDynamicFieldsDefinition {
    my ( $Self, %Param ) = @_;

    # define all fields that are filled out
    my @AllNewFields = ();

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get dynamic field object
    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

    # run all PreFilterModules (modify email params)
    for my $Key ('PostMaster::PreFilterModule')
    {
        if ( ref $ConfigObject->Get($Key) eq 'HASH' ) {
            my %Jobs = %{ $ConfigObject->Get($Key) };

            JOB:
            for my $Job ( sort keys %Jobs ) {
                return if !$MainObject->Require( $Jobs{$Job}->{Module} );
                if (
                    $Jobs{$Job}->{Module} ne 'Kernel::System::PostMaster::Filter::SystemMonitoringX'
                    )
                {
                    next JOB;
                }
                my @NewFields;
                my $FilterObject = $Kernel::OM->Get("$Jobs{$Job}->{Module}");
                if ( !$FilterObject ) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "Can not create $Jobs{$Job}->{Module} object!",
                    );
                    next JOB;
                }

                my $Run = $FilterObject->GetDynamicFieldsDefinition(
                    Config    => $Jobs{$Job},    # the job config
                    NewFields => \@NewFields
                );
                if ( !$Run ) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message =>
                            "Execute GetDynamicFieldsDefinition() of $Key $Jobs{$Job}->{Module} not successful!",
                    );
                }
                else {
                    push @AllNewFields, (@NewFields);
                }
            }
        }
    }

    my $AcknowledgeNameField = $ConfigObject->Get('Tool::Acknowledge::RegistrationAllocation');
    if ($AcknowledgeNameField) {
        if ( $AcknowledgeNameField =~ /\d+/ ) {
            $AcknowledgeNameField = "DynamicField" . $AcknowledgeNameField;
        }
        push @AllNewFields, {
            'Config' => {
                'TranslatableValues' => 1
            },
            'FieldType'  => 'Text',
            'Label'      => 'SystemMonitoring AcknowledgeNameField',
            'Name'       => $AcknowledgeNameField,
            'ObjectType' => 'Ticket'
        };

            # TODO: create all dynamic fields besides of PostMaster-Filter
            # move sub GetDynamicFieldsDefinition from Kernel::System::PostMaster::Filter::SystemMonitoringX
#            push @AllNewFields, {
#            'Config' => {
#                'TranslatableValues' => 1
#            },
#            'FieldType'  => 'Text',
#            'Label'      => 'SystemMonitoring AcknowledgeNameField',
#            'Name'       => $AcknowledgeNameField,
#            'ObjectType' => 'Ticket'
#        };
    }
    return @AllNewFields;
}

1;
