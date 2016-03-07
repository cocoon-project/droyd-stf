*** Settings ***
Documentation     standard tests
...

# libraries
Library    devices.session_proxy.robot_plugin.Pilot
Library    devices.session_proxy.sip_plugin.SipParser

#Suite Setup  init suite
Test Setup     setup pilot     ${platform_name}    ${platform_version}  ${platform_configuration_file}
Test Teardown  close session


*** Variables ***
${platform_name}=   demo
${platform_version}=    demo_qualif


${platform_configuration_file}=  dummy

#${pilot_mode}=  dry
${pilot_mode}=  normal

# demo variables
${sip_local}=  sip:127.0.0.1
${sip_userA}=  ${sip_local}:5061
${sip_userB}=  ${sip_local}:5062


*** Keywords ***

Unit Peer To Peer
    [arguments]  ${userA}  ${userB}  ${format}=universal

    Open session    ${userA}    ${userB}


    #  call userB at 5062
    #call_number  ${userA}  sip:192.168.1.50:5062
    call_number  ${userA}  ${sip_userB}


    # softphone two wait for incoming call and answer
    wait_incoming_call  ${userB}
    answer_call_ok     ${userB}

    # check call
    wait_call_confirmed  ${userA}


    # in communication for delay
    BuiltIn.Sleep  3

    # hangup mobile one
    hangup   ${userA}


    # check all calls disconnected
    wait_call_disconnected   ${userB}

    Close Session




Unit Call With Media
    [arguments]     ${userA}    ${userB}    ${format}
    [Documentation]     $userA call $userB with a specific $format

    Open session    ${userA}    ${userB}

    #Call user   ${userA}   ${userB}   ${format}
    call_number  ${userA}  ${sip_userB}

    Wait incoming Call  ${userB}
    Answer call ok     ${userB}
    Wait Call confirmed     ${userA}



    Start Player    ${userA}
    Watch Log       ${userA}  1

    Start Recorder  ${userB}
    Watch Log       ${userB}  5

    dump call_quality_status  ${userA}
    check_call_quality  ${userB}  min_packets=100  max_loss_rate=0.01  channel=RX

    Stop Recorder  ${userB}
    Watch Log      ${userB}  1

    Stop Player    ${userA}
    Watch Log      ${userA}  1


    Hangup  ${userA}
    Close Session



Unit Send Dtmf
    [arguments]  ${userA}  ${userB}  ${format}

    Open session    ${userA}    ${userB}


    #Call user   ${userA}   ${userB}   ${format}
    call_number  ${userA}  ${sip_userB}


    Wait incoming Call  ${userB}
    Answer call ok     ${userB}
    Wait Call confirmed     ${userA}


    Start Recorder  ${userA}

    # userA send Dtmf sequence to userB
    Send Dtmf  ${userA}  123*#


    # userB checks for incoming dtmf sequence
    Check Dtmf  ${userB}  123*#
    # user B start playing
    Start Player  ${userB}

    # user A checks incoming RTP
    Watch Log       ${userA}  3
    #dump call_quality_status  ${userA}
    check_call_quality  ${userA}  min_packets=100  max_loss_rate=0.01  channel=RX

    Stop Recorder  ${userA}
    Watch Log      ${userA}  1

    Stop Player    ${userB}
    Watch Log      ${userB}  1

    Hangup  ${userA}
    Close Session



*** Test Cases ***


peer_to_peer
  [Tags]  p2p  ok
  [template]  Unit Peer to Peer
  Fred   Fanny     universal


Call With media
  [Tags]  p2p media  ok
  [template]  Unit Call with Media
  Fred  Fanny   universal


Send Dtmf
  [Tags]  p2p media  dtmf  ok
  [template]  Unit Send Dtmf
  Fred    Fanny    universal
#
