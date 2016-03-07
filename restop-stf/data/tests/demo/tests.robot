*** Settings ***
Documentation     standard tests
...

# libraries
#Library    syprunner.robot_plugin.Pilot
#Library    syprunner.sip_plugin.SipParser
Library    devices.session_proxy.robot_plugin.Pilot
Library    devices.session_proxy.sip_plugin.SipParser

#Suite Setup  init suite
Test Setup     setup pilot     ${platform_name}    ${platform_version}  ${platform_configuration_file}
Test Teardown  close session


*** Variables ***
${platform_name}=   demo
${platform_version}=    demo_qualif

#${TEST_HOME}=  /Users/cocoon/Documents/hgclones/syprunner/player/data/robot
#${TEST_HOME}=  /home/vagrant/syprunner/player/data/robot
${platform_configuration_file}=  dummy

#${pilot_mode}=  dry
${pilot_mode}=  normal

# demo variables
${sip_local}=  sip:127.0.0.1
${sip_userA}=  ${sip_local}:5061
${sip_userB}=  ${sip_local}:5062


${Alice_display}=  Alice
${Bob_display}=  Bob
${Charlie_display}=  Charlie


*** Keywords ***

########
init suite
	# check platform capablities with test capablities requirements
	setup pilot 	${platform_name} 	${platform_version}  ${platform_configuration_file}

init pilot
	setup pilot 	${platform_name} 	${platform_version}  ${platform_configuration_file}
	run keyword if   '${pilot_mode}'=='dry'  set pilot dry mode

shutdown pilot
	close session



############### units and macros

Unit dummy operation
	dummy operation



Macro A CALL B
    [arguments]     ${userA}    ${userB}    ${format}
    [Documentation]     $userA call $userB with a specific $format

    Call user   ${userA}   ${userB}   ${format}
    Wait incoming Call  ${userB}
    Answer call ringing     ${userB}
    #Wait ringing    ${userA}
    Answer call ok     ${userB}
    Wait Call confirmed     ${userA}



Macro A Call B redirected to C
    [arguments]     ${userA}  ${userB}  ${userC}    ${call_format}  ${FAC}  ${FAC_call_format}   ${unit}
    # [Documentation]     redirect B to C , A call B , C answer
    # ... @FAC : CFA CFB CFNA CFNR
    # ... @call_format : universal national ..
    # ... @FAC_call_format: universal national , for the redirect
    # ... @unit : the unit to use for a call b , eg: call_no_response call_busy
    Unit Activate Redirection To User   ${userB}  ${userC}  ${FAC}  ${FAC_call_format}
    Run keyword     ${unit}     ${userA}    ${userB}  ${userC}  ${call_format}
    Unit Cancel Redirection  ${userB}  ${FAC}


######### units

Unit Restop Call
	[arguments] 	${userA}	${userB} 	${format}
	[Documentation] 	$userA call $userB with a specific $format

	Open session	${userA}	${userB}

    Call user   ${userA}   ${userB}   ${format}

    Wait Incoming Call  ${userB}
    Answer call ok      ${userB}

    Wait Call confirmed     ${userA}

    Hangup  ${userA}

    Close Session


Unit Basic android call 
    [arguments]   ${userC}  ${userD}  ${format}

    Open session    ${userC}    ${userD}
    BuiltIn.Sleep  5


    # mobile one call mobile two
    call_user  ${userC}  ${userD}


    # mobile one wait for incoming call and answer
    wait_incoming_call  ${userD}
    answer_call_ok      ${userD}


    # checks all calls confirmed
    wait_call_confirmed  ${userC}

    # in communication for delay
    BuiltIn.Sleep  5

    # hangup mobile one
    hangup   ${userC}
 
    # check all calls disconnected
    wait_call_disconnected   ${userD}

    Close Session




Unit Bad Call
	[arguments] 	${userA}	${userB} 	${format}
	[Documentation] 	$userA call $userB with a specific $format

	Open session	${userA}	${userB}

    Bad Call

    Close Session


Unit Something Wrong
	[arguments] 	${userA}	${userB} 	${format}
	[Documentation] 	$userA call $userB with a specific $format

	Open session	${userA}	${userB}

    #Call user   ${userA}   ${userB}   ${format}

    # try to answer a not given call : should end the test
    Answer call ok     ${userB}

    Wait Call confirmed     ${userA}

    Hangup  ${userA}

    Close Session

Unit Simple Call
	[arguments] 	${userA}	${userB} 	${format}
	[Documentation] 	$userA call $userB with a specific $format

	Open session	${userA}	${userB}
    Call user   ${userA}   ${userB}   ${format}
    Wait incoming Call  ${userB}
    Answer call ringing     ${userB}
    Wait ringing    ${userA}
    Answer call ok     ${userB}

    Wait Call confirmed     ${userA}

    Hangup  ${userA}

    Close Session



Unit Call With Media
    [arguments]     ${userA}    ${userB}    ${format}
    [Documentation]     $userA call $userB with a specific $format

    Open session    ${userA}    ${userB}
    Call user   ${userA}   ${userB}   ${format}
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


Unit Double Call
    [arguments]     ${userA}    ${userB}  ${userC}  ${format}=universal
    [Documentation]  A call B , B answer call ,
    ...              C call B , B hold A , B answers C ,
    ...              B hangup C , B unhold A , B hangup  A
    ...  at the end  B.wav contents rtp sent by A , C.wav contents rtp send by B
    ...  and         A.wav content rtp ( music on hold sent by the Application platform )

    Open session    ${userA}    ${userB}  ${userC}

    # A Call B
    Call user   ${userA}   ${userB}   ${format}
    Wait incoming Call  ${userB}
    Answer call ok      ${userB}
    Wait Call confirmed     ${userA}

    # A play , B record
    Start Player    ${userA}
    Start Recorder  ${userB}
    Watch Log       ${userB}  3
    dump call_quality_status  ${userA}
    check_call_quality  ${userB}  min_packets=100  max_loss_rate=0.01  channel=RX

    # C call B
    Call user   ${userC}   ${userB}   ${format}
    Wait incoming Call  ${userB}

    # B hold A
    hold_call  ${userB}    0

    # B answers C
    Answer call ok     ${userB}
    Wait Call confirmed     ${userC}


   # B play , C record
    Start Player    ${userB}
    Start Recorder  ${userC}
    Watch Log       ${userC}  3
    dump call_quality_status  ${userB}
    check_call_quality  ${userC}  min_packets=100  max_loss_rate=0.01  channel=RX


    # B hangup C
    Stop Recorder  ${userC}
    hangup    ${userB}    1


    # B unhold the call with A
    unhold call    ${userB}   0
    Watch Log       ${userB}  3

    dump call_quality_status  ${userA}
    dump call_quality_status  ${userB}   0

    check_call_quality  ${userB}  min_packets=100  max_loss_rate=0.01  channel=RX   call_indice=0


    #Stop Recorder  ${userB}
    #Stop Player    ${userA}


    # B hangup A
    Hangup  ${userB}    0

    # C hangup B
    #Hangup  ${userC}

    Close Session


Unit blind transfer ABBC
    [arguments]     ${userA}    ${userB}  ${userC}  ${format}=universal
    [Documentation]  A call B , B transfer call to C:
    ...              A call B , B answer call ,
    ...              B transfer call to C , C answers
    ...              C hangup
    ...  at the end  B.wav contents rtp sent by A , C.wav contents rtp send by A
    ...  and         A.wav content no sound

    Open session    ${userA}    ${userB}  ${userC}

    # A Call B
    Call user   ${userA}   ${userB}   ${format}
    Wait incoming Call  ${userB}
    Answer call ok     ${userB}
    Wait Call confirmed     ${userA}

    # A play , B record
    Start Player    ${userA}
    Start Recorder  ${userB}
    Watch Log       ${userB}  3
    dump call_quality_status  ${userA}
    check_call_quality  ${userB}  min_packets=100  max_loss_rate=0.01  channel=RX

    # B transfer call to C ( blind )
    Stop Recorder  ${userB}
    transfer to user  ${userB}  ${userC}  ${format}
    Wait incoming Call  ${userC}
    Answer call ok     ${userC}

    # A is in communication with C
    # A play , C record
    Start Recorder  ${userC}
    Watch Log       ${userC}  3
    dump call_quality_status  ${userA}
    check_call_quality  ${userC}  min_packets=100  max_loss_rate=0.01  channel=RX


    # C hangup
    Stop Recorder  ${userC}
    Hangup  ${userC}


    Close Session


Unit blind transfer ABAC
    [arguments]     ${userA}    ${userB}  ${userC}  ${format}=universal
    [Documentation]  A call B , A transfer call to C:
    ...              A call B , B answer call ,
    ...              A hold B , A transfer call to C , C answers
    ...              C hangup
    ...  at the end  B.wav contents rtp sent by A and music on hold , C.wav contents rtp send by B
    ...  and         A.wav content no sound

    Open session    ${userA}    ${userB}  ${userC}

    # A Call B
    Call user   ${userA}   ${userB}   ${format}
    Wait incoming Call  ${userB}
    Answer call ok     ${userB}
    Wait Call confirmed     ${userA}

    # A play , B record
    Start Player    ${userA}
    Start Recorder  ${userB}
    Watch Log       ${userB}  3
    dump call_quality_status  ${userA}
    check_call_quality  ${userB}  min_packets=100  max_loss_rate=0.01  channel=RX


    # A hold B , and A call C
    hold_call  ${userA}
    Call user   ${userA}   ${userC}   ${format}
    Wait incoming Call  ${userC}
    Answer call ok     ${userC}
    Wait Call confirmed     ${userA}


    # A transfer call to C ( blind )
    select previous call  ${userA}
    # previous call selected to transfer the right call
    transfer to user  ${userA}  ${userC}  ${format}
    Wait incoming Call  ${userC}
    Answer call ok     ${userC}

    # B is in communication with C
    # B play , C record
    Start Recorder  ${userC}
    Start Player    ${userB}
    Watch Log       ${userC}  3

    # dump the user B
    dump call_quality_status  ${userB}  call_indice=0

    # dump user C call 0 : the connection with A ( no sound exchanged)
    dump call_quality_status  ${userC}  call_indice=0

    # dump user C call 1 : the connection with B ( receive rtp from B)
    dump call_quality_status  ${userC}  call_indice=1

    check_call_quality  ${userC}  min_packets=100  max_loss_rate=0.01  channel=RX  call_indice=1


    # C hangup
    Stop Recorder  ${userC}
    Hangup  ${userC}


    Close Session



Unit simple incoming call checks
    [arguments]     ${userA}    ${userB}   ${format}
    [Documentation]  A call B , B checks incoming call is coming from A

    Open session    ${userA}    ${userB}

    # A Call B
    Call user   ${userA}   ${userB}   ${format}
    wait incoming call  ${userB}

    ${caller_info}=  Ptf Get User Data  ${userA}
    Log Many  ${caller_info}
    check incoming call  ${userB}  display_name=${caller_info['format_universal']}
    #check incoming call  ${userB}  display_name=${Alice_display}
    Answer call ok     ${userB}
    Wait Call confirmed     ${userA}


    hangup    ${userA}
    Close Session


Unit complex incoming call checks
    [arguments]     ${userA}    ${userB}   ${format}
    [Documentation]  A call B , B checks incoming call is coming from A



    Open session    ${userA}    ${userB}

    # A Call B
    Call user   ${userA}   ${userB}   ${format}
    wait incoming call  ${userB}

    # get the sip request INVITE message of the incoming call
    ${sip_message}=  get last received sip request  ${userB}  sip_method=INVITE

    Answer call ok     ${userB}
    Wait Call confirmed     ${userA}

    # get calller info from configuration
    ${caller_info}=  Ptf Get User Data  ${userA}

    Log Many  ${caller_info}

    # check from header display
    ${display_name}=  sip from display  ${sip_message}
    Should be equal  ${display_name}  ${caller_info['format_universal']}

    # performs cheks on sip message
    ${method}=  sip_method  ${sip_message}
    log  ${method}

    ${method}=  sip_protocol  ${sip_message}
    log  ${method}

    ${method}=  sip_cseq_number  ${sip_message}
    log  ${method}

    ${method}=  sip_content_type  ${sip_message}
    log  ${method}

    ${method}=  sip_call_id  ${sip_message}
    log  ${method}

    ${info}=  sip_from_display  ${sip_message}
    log  ${info}
    Should be equal  ${info}  ${caller_info['format_universal']}

    ${info}=  sip_from_displayable  ${sip_message}
    log  ${info}
    Should be equal  ${info}   ${caller_info['format_universal']}

    ${method}=  sip_from_user  ${sip_message}
    log  ${method}

    ${method}=  sip_from_host  ${sip_message}
    log  ${method}

    ${method}=  sip_to_user  ${sip_message}
    log  ${method}

    ${method}=  sip_to_host  ${sip_message}
    log  ${method}

    ${method}=  sip_to_port  ${sip_message}
    log  ${method}

    ${method}=  sip_sdp_originator_address  ${sip_message}
    log  ${method}



    hangup    ${userA}
    Close Session


Unit attended transfer ABBC
    [arguments]     ${userA}    ${userB}  ${userC}  ${format}
    [Documentation]  A call B , B transfer call to C:
    ...              A call B , B answer call ,
    ...              B hold A , B transfer call to C , C answers
    ...              C hangup
    ...  at the end  A.wav contents rtp sent by AS (music on hold),
    ...              B.wav contents rtp sent by A
    ...  and         C.wav contents rtp sent by B then rtp sent by A

    Open session    ${userA}    ${userB}  ${userC}

    # A Call B
    Call user   ${userA}   ${userB}   ${format}
    Wait incoming Call  ${userB}
    Answer call ok     ${userB}
    Wait Call confirmed     ${userA}

    # A play , B record
    Start Player    ${userA}
    Start Recorder  ${userB}
    Watch Log       ${userB}  3
    dump call_quality_status  ${userA}
    check_call_quality  ${userB}  min_packets=100  max_loss_rate=0.01  channel=RX


    # B put call A B on hold
    Hold call  ${userB}
    Start Recorder  ${userA}

    # B call C
    Call user   ${userB}   ${userC}   ${format}
    Wait incoming Call  ${userC}
    Answer call ok     ${userC}
    Wait Call confirmed     ${userB}


    # B play , C record
    Start Player    ${userB}
    Start Recorder  ${userC}
    Watch Log       ${userC}  3
    dump call_quality_status  ${userB}
    check_call_quality  ${userC}  min_packets=100  max_loss_rate=0.01  channel=RX



    # B put the call with C on hold
    Stop Recorder  ${userB}
    hold call  ${userB}

    # B transfer the call with A  (indice 0) to the current call to C (indice 1)
    transfer_attended  ${userB}  0
    wait incoming request  ${userB}  operation=BYE

    # A is in now in communication with C
    # A play , C record
    #Start Recorder  ${userC}
    Watch Log       ${userC}  3



    dump call_quality_status  ${userA}
    dump call_quality_status  ${userC}  call_indice=0
    #dump call_quality_status  ${userC}  call_indice=1
    check_call_quality  ${userC}  min_packets=100  max_loss_rate=0.01  channel=RX  call_indice=0


    # C hangup
    Stop Recorder  ${userC}
    Hangup  ${userC}


    Close Session


Unit attended transfer ABAC
    [arguments]     ${userA}    ${userB}  ${userC}  ${format}
    [Documentation]  A call B , A call C  , A transfer call to C:
    ...              A call B , B answer call ,
    ...              A hold B , A transfer call to C
    ...              C hangup
    ...  at the end  A.wav contents no sound
    ...              B.wav contents rtp sent by A then rtp from AS ( music on homd)
    ...  and         C.wav contents rtp sent by A then rtp sent by B

    Open session    ${userA}    ${userB}  ${userC}

    # A Call B
    Call user   ${userA}   ${userB}   ${format}
    Wait incoming Call  ${userB}
    Answer call ok     ${userB}
    Wait Call confirmed     ${userA}

    # A play , B record
    Start Player    ${userA}
    Start Recorder  ${userB}
    Watch Log       ${userB}  3
    dump call_quality_status  ${userA}
    check_call_quality  ${userB}  min_packets=100  max_loss_rate=0.01  channel=RX


    # A put call A B on hold
    Hold call  ${userA}


    # A call C
    Call user   ${userA}   ${userC}   ${format}
    Wait incoming Call  ${userC}
    Answer call ok     ${userC}
    Wait Call confirmed     ${userA}


    # A play , C record
    start Player    ${userA}
    Start Recorder  ${userC}
    Watch Log       ${userC}  3
    dump call_quality_status  ${userA}
    check_call_quality  ${userC}  min_packets=100  max_loss_rate=0.01  channel=RX



    # A put the call with C on hold
    hold call  ${userA}

    # A transfer the call with C  (indice 0) to the current call to B (indice 1)
    transfer_attended  ${userA}  0
    wait incoming request  ${userA}  operation=BYE
    watch log  ${userB}  1
    watch log  ${userC}  1

    # B is in now in communication with C
    # B play , C record
    #select previous call  ${userB}
    Start player  ${userB}
    Start Recorder  ${userC}
    Watch Log       ${userC}  3



    dump call_quality_status  ${userB}
    dump call_quality_status  ${userC}  call_indice=0
    check_call_quality  ${userC}  min_packets=100  max_loss_rate=0.01  channel=RX  call_indice=0


    # C hangup
    Stop Recorder  ${userC}
    Hangup  ${userC}


    Close Session


unit test check not received
    [arguments]     ${userA}    ${userB}    ${userC}  ${refresh_count}=1
    [Documentation]     A call B, check C receive no INVITE


    Open session    ${userA}    ${userB}    ${userC}
    BuiltIn.Sleep  3

    Call user   ${userA}   ${userB}     universal
    Wait incoming Call  ${userB}
    Answer call ringing     ${userB}
    #Wait ringing    ${userA}
    Answer call ok     ${userB}

    Wait Call confirmed     ${userA}

    check no incoming call received     ${userC}  ${refresh_count}

    Hangup  ${userA}

    Close Session

# Unit Call Feature Access Code
# 	[arguments] 	${userA}	${FeatureAccessCode}
# 	[Documentation] 	call with a feature access code

# 	Open session	${userA}

#     Call Feature Access Code   ${userA}    ${FeatureAccessCode}
#     Wait Hangup  ${userA}

#     Close Session

Macro Activate Redirection To User
    [Documentation]     redirect A to B with a kind of redirection and call format
    [arguments]     ${userA}  ${userB}  ${redirect_kind}=CFA  ${call_format}=universal

    activate redirection to user   ${userA}  ${userB}  ${redirect_kind}  ${call_format}
    wait call confirmed  ${userA}
    Wait Hangup  ${userA}

Macro Cancel Redirection
    [arguments]     ${user}    ${FAC_kind}
    [Documentation]     cancel a redirection  (kind can be CFA,CFB,CFNA,CFNR)
    Cancel Redirection   ${user}    ${FAC_kind}
    wait call confirmed  ${user}
    Wait Hangup  ${user}





Unit Activate Redirection To User
    [Documentation]     redirect A to B with a kind of redirection and call format
    [arguments]     ${userA}  ${userB}  ${redirect_kind}=CFA  ${call_format}=universal


    Open session    ${userA}
    activate redirection to user   ${userA}  ${userB}  ${redirect_kind}  ${call_format}
    Wait Hangup  ${userA}

    Close Session


Unit Cancel Redirection
    [arguments]     ${userA}    ${FAC_kind}
    [Documentation]     cancel a redirection  (kind can be CFA,CFB,CFNA,CFNR)

    Open session    ${userA}

    Cancel Redirection   ${userA}    ${FAC_kind}
    Wait Hangup  ${userA}

    Close Session


Unit Bad Feature Access Code
    [arguments]     ${userA}    ${FeatureAccessCode}
    [Documentation]     call with a bad feature access code should fail
    Open session  ${userA}

    #Run Keyword And Expect Error    KO    Bad call
    ${result}=  Bad call
    Should Be Equal     ${result}   KO

    Wait Hangup  ${userA}

    Close Session


Unit A Call B redirected to C
    [arguments]     ${userA}    ${userB}    ${userC}  ${redirect_kind}=CFA  ${call_format}=universal
    [Documentation]     $userA call $userB with a specific $format

    Open session     ${userA}    ${userB}   ${userC}

    # activate redirection for B to C
    Macro Activate Redirection To User  ${userB}  ${userC}  ${redirect_kind}  ${call_format}

    # A call B , C answers
    Call user   ${userA}   ${userB}   ${call_format}
    Wait incoming Call  ${userC}
    Answer call ok     ${userC}
    Wait Call confirmed     ${userA}
    watch log  ${userA}  1
    Hangup  ${userA}

    # cancel redirection for B
    Macro Cancel Redirection  ${userB}    ${redirect_kind}

    close session

Unit A Call B redirected to C on no answer
    [arguments]     ${userA}    ${userB}    ${userC}  ${redirect_kind}=CFNA  ${call_format}=universal
    [Documentation]     $userA call $userB with a specific $format

    Open session     ${userA}    ${userB}   ${userC}

    # activate redirection for B to C
    Macro Activate Redirection To User  ${userB}  ${userC}  ${redirect_kind}  ${call_format}

    # A call B , C answers
    Call user   ${userA}   ${userB}   ${call_format}

    # B dont answer
    watch log   ${userB}  1

    Wait incoming Call  ${userC}
    Answer call ok     ${userC}
    Wait Call confirmed     ${userA}
    watch log  ${userA}  1
    Hangup  ${userA}

    # cancel redirection for B
    Macro Cancel Redirection  ${userB}    ${redirect_kind}

    close session



Unit A Call B redirected to C on busy
    [arguments]     ${userA}    ${userB}    ${userC}    ${userD}    ${call_format}=universal
        # [Documentation] prerequisite: userB is redirected to userC on busy
        # ... userD call userB ,so userB is busy
        # ... userA call userB with a specific $call_format , call is redirected to userC
        # ... userC answers
        # ... userA hangups
        # ... userD hangups

    Open session     ${userA}    ${userB}   ${userC}   ${userD}

    # activate redirection for B to C on busy
    Macro Activate Redirection To User  ${userB}  ${userC}  CFB  ${call_format}
    #activate redirection to user   ${userA}  ${userB}  CFB  ${call_format}


    call user   ${userD}  ${userB}    ${call_format}
    wait incoming call and answer ok    ${userB}
    wait call confirmed  ${userD}

    Call user   ${userA}   ${userB}   ${call_format}
    wait incoming call  ${userB}
    answer call  ${userB}  486


    Wait incoming Call and answer ok    ${userC}
    Wait Call confirmed     ${userA}
    Hangup  ${userA}
    Hangup  ${userD}

    # cancel redirection for B
    Macro Cancel Redirection  ${userB}    CFB
    Close session

Unit complex redirection
    [arguments]     ${userA}    ${userB}    ${userC}    ${userD}  ${userE}  ${call_format}=universal
    # [Documentation] prerequisite: B is CFA to C, C is CFB to D , D is CFNA to E
    # ... A call B with a specific $call_format , call is redirected to C (CFA)
    # ... C answers busy , call is redirected to D
    # ... D dont answer , call is redirected to E
    # ... E answers
    # ... userA hangups

    Open session     ${userA}    ${userB}   ${userC}   ${userD}  ${userE}

    Call user   ${userA}   ${userB}   ${call_format}
    # C answers busy
    wait incoming call  ${userC}
    answer call  ${userC}  486
    # D dont answers
    wait incoming call  ${userD}
    watch log  ${userD}  1
    # E answers
    Wait incoming Call and answer ok    ${userE}
    Wait Call confirmed     ${userA}
    watch log  ${userA}

    Hangup  ${userA}

    Close session


Unit A Call B redirected to C on not reachable
    [arguments]     ${userA}    ${userB}    ${userC}   ${call_format}=universal
        # [Documentation] prerequisite: userB is redirected to userC on not reachable
        # ... B unregister so B is unreachable
        # ... userA call userB with a specific $call_format , call is redirected to userC
        # ... userC answers
        # ... userA hangups
    Open session     ${userA}    ${userB}   ${userC}

    Unregister  ${userB}

    Call user   ${userA}   ${userB}   ${call_format}

    Wait incoming Call and answer ok    ${userC}
    Wait Call confirmed     ${userA}
    Hangup  ${userA}

    # cancel redirection for B
    #Macro Cancel Redirection  ${userB}    CFB
    Close session


Unit A Call B redirected to C on rejected
    [arguments]     ${userA}    ${userB}    ${userC}   ${call_format}=universal
        # [Documentation] prerequisite: userB is redirected to userC on not reachable
        # ... userA call userB with a specific $call_format
        # ... B reject call (487) so call redirectd to C
        # ... userC answers
        # ... userA hangups
    Open session     ${userA}    ${userB}   ${userC}

    Call user   ${userA}   ${userB}   ${call_format}
    # B reject call
    wait incoming call  ${userB}
    answer call  ${userB}  487
    # C answers
    Wait incoming Call and answer ok    ${userC}
    Wait Call confirmed     ${userA}
    Hangup  ${userA}

    # cancel redirection for B
    #Macro Cancel Redirection  ${userB}    CFB
    Close session




Unit Dummy
    [arguments]     ${userA}    ${userB}    ${userC}    ${userD}    ${call_format}

    Open Session     ${userA}    ${userB}    ${userC}    ${userD}
    sleep(2)
    Close Session


Unit call music
  [arguments]  ${user}
  Open session     ${user}
  call destination  ${user}  music2

  wait call confirmed  ${user}
  start recorder  ${user}
  watch log  ${user}  5

  stop recorder  ${user}

  hangup  ${user}
  Close session


Unit call number
  [arguments]  ${user}  ${number}
  Open session     ${user}
  call number  ${user}  ${number}
  wait call confirmed  ${user}
  #BuiltIn.Sleep  2
  wait hangup  ${user}
  Close session


Unit Get User Info
  [arguments]  ${user}
  Open session     ${user}

  ${user_data}=  Ptf Get User Data  ${user}
  Log Many  ${user_data}

  Close session


Unit Send Dtmf
    [arguments]  ${userA}  ${userB}  ${format}

    Open session    ${userA}    ${userB}
    Call user   ${userA}   ${userB}   ${format}
    Wait incoming Call  ${userB}
    Answer call ok     ${userB}
    Wait Call confirmed     ${userA}

    #Start Player    ${userA}
    #Watch Log       ${userA}  1

    Start Recorder  ${userB}

    #Send Dtmf  ${userA}  "1234567890*#"
    Send Dtmf  ${userA}  "1"
    Watch Log       ${userB}  1

    Start Player  ${userA}
    Watch Log       ${userA}  3

    dump call_quality_status  ${userA}
    check_call_quality  ${userB}  min_packets=100  max_loss_rate=0.01  channel=RX

    Stop Recorder  ${userB}
    Watch Log      ${userB}  1

    Stop Player    ${userA}
    Watch Log      ${userA}  1


    Hangup  ${userA}
    Close Session





Unit Basic sip and android
    [arguments]  ${userA}  ${userB}  ${userC}  ${userD}  ${format}

    Open session    ${userA}    ${userB}   ${userC}    ${userD}
    BuiltIn.Sleep  5


    # mobile one call mobile two
    call_user  ${userC}  ${userD}

    # softphone one call softphone two
    call_user  ${userA}  ${userB}


    # softphone two wait for incoming call and answer
    wait_incoming_call  ${userB}
    answer_call_ok     ${userB}


    # mobile one wait for incoming call and answer
    wait_incoming_call  ${userD}
    answer_call_ok      ${userD}


    # checks all calls confirmed
    wait_call_confirmed  ${userA}
    wait_call_confirmed  ${userC}

    # in communication for delay
    BuiltIn.Sleep  5

    # hangup mobile one
    hangup   ${userC}
    # hangup softphone one
    hangup   ${userA}


    # check all calls disconnected
    wait_call_disconnected   ${userB}
    wait_call_disconnected   ${userD}

    Close Session







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





*** Test Cases ***


peer_to_peer
  [Tags]  p2p  ok
  [template]  Unit Peer to Peer
  Fred   Fanny     universal


restop_call
  [Tags]  simple  1  blueswitch  ok
  [template]  Unit restop Call
  Alice   Bob     universal
#
#
basic sip and android
    [Tags]  sip_android  blueswitch  ok

    [template]  Unit Basic Sip And Android
    Alice   Bob  Mobby  Marylin   universal


#bad_call
#  [Tags]  error
#  [template]  Unit Bad Call
#  Alice   Bob     universal
#
#
#something_wrong
#  [Tags]  error
#  [template]  Unit something wrong
#  Alice   Bob     universal


#"01 test configuration platform"
#   Unit get platform configuration

#"02 test common unit"
#   unit dummy operation


#"00-check not received"
#  [Tags]  simple  1 blueswitch ok
#   unit test check not received    Alice   Bob     Charlie
#
#"01-Basicalls/simple_call"
#  [Tags]  simple  1 blueswitch
#  [template]  Unit Simple Call
#  Alice   Bob     universal


#Call With media
#  [Tags]  media  1  blueswitch
#  [template]  Unit Call with Media
#  Alice    Bob    ext

Call With media
  [Tags]  media  1  blueswitch  ok
  [template]  Unit Call with Media
  Aline  Bruce   universal

#
#
#
simple incoming call checks
  [tags]  checks  2    blueswitch  ok
  [template]  Unit simple incoming call checks
  Alice    Bob    ext

complex incoming call checks
  [tags]  checks  2    blueswitch  ok
  [template]  Unit complex incoming call checks
  Alice    Bob    ext



#Double Call
#  [tags]    double  3
#  [template]  Unit Double Call
#  Aline  Bruce  Bruce_InterSite


#  Alice  Bob  Charlie  universal



#


#  Alice    Bob    Charlie    ext


Blind transfer ABBC
  [tags]  transfer  4
  [template]  Unit blind transfer ABBC
  Alice    Bob    Charlie    ext

#
#Blind transfer ABAC
#  [tags]  transfer  4
#  [template]  Unit blind transfer ABAC
#  Alice    Bob    Charlie    ext
#
#
#
#attended transfer ABBC
#   [tags]  transfer2  5
#   [template]  Unit attended transfer ABBC
#   Alice    Bob    Charlie    ext
#
#attended transfer ABAC
#   [tags]  transfer2  5
#   [template]  Unit attended transfer ABAC
#   Alice    Bob    Charlie    ext
#
#
#
simple call full numbers
  [Tags]  full    blueswitch  ok
  [template]  Unit Call with media
  Aline   Bruce     universal
  Aline   Bruce     national
  Aline   Bruce     international
  Aline   Bruce_InterEnterprise  universal
  Aline   Bruce_InterEnterprise  international
  Aline   Bruce_InterEnterprise  national
#
#
simple call local numbers
  [Tags]  bluebox_local  ok
  [template]  Unit Restop Call
  Aline   Bruce     ext
  Aline   Bruce     sid_ext
  Aline   Aline_InterSite  sid_ext
  Aline   Aline_InterSite  ext
  #Aline   Aline_InterEnterprise  sid_ext
#
#
#transfer test
#  [Tags]  bluebox_transfer
#  open session   Aline  Bruce
#  call destination  Aline  transfer
#  wait incoming call  Bruce
#  answer call ok  Bruce
#  wait call confirmed  Aline
#  watch log  Aline  2
#  hangup  Aline
#  Close session
#
#
## call music
##   [Tags]  music
##   unit call music  Aline
#
#
## fac
##   [Tags]  fac
##    [template]  Unit call number
##    Aline  sip:*20110146511102@bluebox
##    Aline  sip:*20210146511103@bluebox
##    Aline  sip:*20310146511104@bluebox
##    Aline  sip:*20410146511104@bluebox
##    Aline  sip:*2040@bluebox
#
#

fac activate
  [Tags]  fac  ok
  [template]  Unit Activate Redirection To User
  Aline  Bruce  CFA
  Aline  Bruce  CFB  national
  Aline  Bruce  CFNA  international
  Aline  Bruce  CFNR  sid_ext
  Bruce  Aline  CFA  ext

fac deactivate
  [Tags]  fac  ok
  [template]  Unit Cancel Redirection
  Aline  CFA
  Aline  CFB
  Aline  CFNA
  Aline  CFNR
  Bruce  CFA
  Bruce  CFB
  Bruce  CFNA
  Bruce  CFNR

#
redirect call always
  [Tags]  redirect always  ok
  [template]  Unit A Call B redirected to C
  Aline  Bruce  Bruce_InterSite
#
#redirect call busy
#  [Tags]  redirect_busy
#  #Unit Activate Redirection To User  Bruce  Bruce_InterSite  CFB
#  Unit A Call B redirected to C on busy  Aline  Bruce  Bruce_InterSite  Aline_InterSite
#  #Unit Cancel Redirection  Bruce  CFB

#redirect call on no answer
#  [Tags]  redirect noanswer
#  #Unit Activate Redirection To User  Bruce  Bruce_InterSite  CFNA
#  Unit A Call B redirected to C on no answer  Aline  Bruce  Bruce_InterSite
#  #Unit Cancel Redirection  Bruce  CFNA
#
#
#complex redirection
#  [Tags]  redirect  complex
#  # setup redirection
#  Unit Activate Redirection To User  Bruce  Charlene  CFA
#  Unit Activate Redirection To User  Charlene  David  CFB
#  Unit Activate Redirection To User  David  Bruce_InterSite  CFNA
#  # call
#  Unit complex redirection  Aline  Bruce  Charlene  David  Bruce_InterSite
#  # clean redirection
#  Unit Cancel Redirection  Bruce  CFA
#  Unit Cancel Redirection  Charlene  CFB
#  Unit Cancel Redirection  David  CFNA
#
#redirect call not reachable
#  [Tags]  redirect  not_reachable
#  Unit Activate Redirection To User  Bruce  Charlene  CFNR
#  Unit A Call B redirected to C on not reachable  Aline  Bruce  Charlene
#  Unit Cancel Redirection  Bruce  CFNR
#
#redirect call rejected
#  [Tags]  redirect  rejected
#  Unit Activate Redirection To User  Bruce  Charlene  CFNR
#  Unit A Call B redirected to C on rejected  Aline  Bruce  Charlene
#  Unit Cancel Redirection  Bruce  CFNR

#
#Get User Info
#    [tags]  ptf
#    Unit Get User Info  Alice
#    Unit Get User Info  Aline
#
#
Send Dtmf
  [Tags]  media  dtmf
  [template]  Unit Send Dtmf
  Aline    Bruce    universal
#
#
unit check no incoming call received
  [Tags]  not_received   ok
  [template]  unit test check not received
  Aline  Bruce  Charlene
  Aline  Bruce  Charlene  3
  Aline  Bruce  Charlene  0


basic android call
  [Tags]  android

  [template]  Unit Basic Android Call
  Mobby  Marylin   universal



