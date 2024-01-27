*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections

*** Test Cases ***

# Lue verkkosivujen osoitteet tiedostosta ja tallenna ne muuttujaan
Read Webpages Text
    ${webpages_directory}    Set Variable    "File path"
    ${webpages_file_contents}    Get File    ${webpages_directory}/webpages.txt
    ${webpage_addresses}=    Split String    ${webpages_file_contents}
    
    Log    Contents of webpages file:\n${webpage_addresses}
    Set Global Variable    ${webpage_addresses}

# Luo tyhjä tiedosto IP-osoitteille
Create IP Addresses File
    ${ip_addresses_directory}=    Set Variable    "File Path"
    Create File    ${ip_addresses_directory}/ipaddresses.txt

    File Should Exist    ${ip_addresses_directory}/ipaddresses.txt
    File Should Be Empty    ${ip_addresses_directory}/ipaddresses.txt

# Käsittele IP-osoitteita ja niiden ping-vastauksia
Calculate IP Addresses
    ${ip_addresses_directory}=    Set Variable    "File Path"
    ${address_count}=    Get Length    ${webpage_addresses}

    FOR    ${current_index}    IN RANGE    ${address_count}
        ${ping_result}=    Run And Return Rc And Output    ping ${webpage_addresses}[${current_index}]
        @{ping_output_words}=    Split String    ${ping_result}[1]
        
        ${ping_index}=    Get Index From List    ${ping_output_words}    Pinging
        ${ping_index}=    Evaluate    ${ping_index}+2
        ${ip_address}=    Set Variable    ${ping_output_words}[${ping_index}]
        
        ${average_index}=    Get Index From List    ${ping_output_words}    Average
        ${average_index}=    Evaluate    ${average_index}+2
        ${average_value}=    Set Variable    ${ping_output_words}[${average_index}]
        
        ${average_number}=    Set Variable    ${average_value}[:-2]
        ${average_number_only}=    Convert To Number    ${average_number}
        
        # Tarkista, onko aika alle 50 ms
        Should Be True    ${average_number_only} < 50.0
        
        # Lisää IP-osoite ja vasteaika tiedostoon
        Append To File    ${ip_addresses_directory}/ipaddresses.txt    IP Address: ${ip_address}, Average: ${average_value}\n

    END


               