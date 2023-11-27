
*** Settings ***
Library    RPA.Windows
Library    RPA.Excel.Files
Library    RPA.Tables
Library    String
Library    DateTime
Library    RPA.Desktop
Library    OperatingSystem
# Library    openpyxl
# Library    Collections
# Library    RPA.FTP






*** Variables ***
${PRIMER_NAME}=
${SEGUNDO_NAME}=
${excel_file} =    C:\\Users\\zcheveste\\Documents\\Robocop_project\\Robot_Comprobante\\Excels\\MATRIZ CENTRAL.xlsx
${excel_file2} =    C:\\Users\\zcheveste\\Documents\\Robocop_project\\OCR\\facturas\\Facturas de Aysa - Bot\\facturas_aysa.xlsx
${excel_file3} =    C:\\Users\\zcheveste\\Documents\\Robocop_project\\OCR\\comprobantes\\Comprobantes.xlsx
${sheet_name} =    SERVICIOS_PUBLICOS
${sheet_name2} =    Facturas Aysa
${sheet_name3} =    Compromisos
${contador}    0
${value_to_write} =    OK
${value_to_write1} =    SI EXISTE
${column_name} =    E
${column_name1} =    I
${column_name2} =    J
${texto_del_cartel}=    existe
${ruta_base} =    C:\\Users\\zcheveste\\Documents  
${nombre_carpeta} =    DevengadosPdf

*** Tasks ***
Open Major desktop application and play a app
    # Open the Major.Exe desktop application 
    Creacion de Carpetas
    Ir a incio de usuario 
    Carga de datos

*** Keywords ***

Open the Major.Exe desktop application

    #Iniciar el sistema Major 
    Windows Run    Major.Exe    
    Sleep    5s

    #Apreta click en el cuadro de contabilidad
    RPA.Windows.Click    id:25    timeout=30
    Sleep    40s

    #Clickea el nombre de usuario y lo carga
    RPA.Windows.Click    id:6    timeout=120
    Send Keys    keys=${PRIMER_NAME}KTURKI

    #Clickea la contraseña de usuario y la carga 
    RPA.Windows.Click    id:5    
    Send Keys    keys=${SEGUNDO_NAME}37792827
    
    # Iniciar Usuario
    RPA.Windows.Click    id:4
    Sleep    15s

Creacion de Carpetas

    ${fecha_hoy} =    Get Current Date
    ${año} =    Convert Date    ${fecha_hoy}    %Y
    ${mes} =    Convert Date    ${fecha_hoy}    %m
    ${día} =    Convert Date    ${fecha_hoy}    %d

    # Ruta completa de la carpeta
    ${ruta_año}    Set Variable    ${ruta_base}\\${año}
    ${ruta_mes}    Set Variable    ${ruta_año}\\${mes}
    ${ruta_dia}    Set Variable    ${ruta_mes}\\${día}
    ${ruta_carpeta}    Set Variable    ${ruta_dia}\\${nombre_carpeta}

    # Verificar y crear la carpeta de año
    ${existe_carpeta_año}    Run Keyword And Return Status    Directory Should Exist    ${ruta_año}
    Run Keyword If    not ${existe_carpeta_año}    Create Directory    ${ruta_año}

    # Verificar y crear la carpeta de mes
    ${existe_carpeta_mes}    Run Keyword And Return Status    Directory Should Exist    ${ruta_mes}
    Run Keyword If    not ${existe_carpeta_mes}    Create Directory    ${ruta_mes}

    # Verificar y crear la carpeta de día
    ${existe_carpeta_día}    Run Keyword And Return Status    Directory Should Exist    ${ruta_dia}
    Run Keyword If    not ${existe_carpeta_día}    Create Directory    ${ruta_dia}

    # Verificar y crear la carpeta específica
    ${existe_carpeta_especifica}    Run Keyword And Return Status    Directory Should Exist    ${ruta_carpeta}
    Run Keyword If    not ${existe_carpeta_especifica}    Create Directory    ${ruta_carpeta}
    
Ir a incio de usuario

    ## ir a Transacciones
    RPA.Windows.Click    name:Transacciones    timeout=60

    ## ir a Comprobantes
    RPA.Windows.Click    name:Comprobantes    timeout=30
Carga de datos 

    #Abrir el excel de la matriz central y crear una lista de donde sacar los datos 
    RPA.Excel.Files.Open Workbook    ${excel_file}

    ${data_as_table} =    Read Worksheet As Table    ${sheet_name}    header=True

    @{cuenta} =    Create List  # Crear una lista vacía para almacenar los datos de las columnas

    #Abrir el excel de facturas aysa y crear una lista de donde sacar los datos 
    RPA.Excel.Files.Open Workbook    ${excel_file2}

    ${data_as_table2} =    Read Worksheet As Table    ${sheet_name2}    header=True

    @{n_cuenta2} =    Create List  # Crear una lista vacía para almacenar los datos de las columnas

    #Crear columnas
    ${contadorROW2}    Set Variable    2  
    Set Cell Value    1    F    TIPOFB
    Set Cell Value    1    G    ORDEN1
    #En la columna H se encuentra "COMPROMISOS"
    Set Cell Value    1    I    COMPROBANTES
    Set Cell Value    1    J    DEVENGADOS

    FOR    ${row2}    IN    @{data_as_table2}
        Set Cell Value    ${contadorROW2}    F    45
        Set Cell Value    ${contadorROW2}    G    ${contadorROW2}
        ${contadorROW2}    Evaluate    ${contadorROW2} + 1
    END

    ${data_as_table2} =    Read Worksheet As Table    ${sheet_name2}    header=True

    Save Workbook

    #Abrir el excel de los compromisos y crear una lista de donde sacar los datos 
    RPA.Excel.Files.Open Workbook    ${excel_file3}
    ${data_as_table3} =    Read Worksheet As Table    ${sheet_name3}    header=True

    @{n_cuenta3} =    Create List  # Crear una lista vacía para almacenar los datos de las columnas

    Set Cell Value    1    D    ORDEN
    Set Cell Value    1    E    ESTADO

    ${contadorROW3}    Set Variable    2  # Puedes ajustar el valor inicial según tus necesidades
    
    FOR    ${row3}    IN    @{data_as_table3}
        Set Cell Value    ${contadorROW3}    D    ${contadorROW3}
        ${contadorROW3}    Evaluate    ${contadorROW3} + 1
    END

    ${data_as_table3} =    Read Worksheet As Table    ${sheet_name3}    header=True

    Save Workbook
    
    # Filtrar la matriz central por los servicios de agua 
    ${filtered_data} =    Filter Table By Column    ${data_as_table}    SERVICIO    ==    AGUA
    Log    ${filtered_data}

    FOR    ${row3}    IN    @{data_as_table3}
    ${n_cuenta3} =    Set Variable    ${row3["Numero_cuenta"]}
        ${estado} =    Set Variable    ${row3["ESTADO"]}

        #Iterar sobre las filas de la columna estado para saber si el compromiso ya fue cargado anteriormente o no, los compromisos cargados deberan tener escrito un "OK" en la columna "ESTADO"
        IF    '${estado}' != 'OK'
        Log    Checking row con el estado
        ELSE
            Continue For Loop If    '${estado}' == 'OK'
        Log    Skipping row with "OK"
        END

        FOR    ${row2}    IN    @{data_as_table2}

        ${n_cuenta2} =    Set Variable    ${row2["N° de Cuenta"]}
        ${comprobante} =    Set Variable    ${row2["COMPROBANTES"]}

        #Iterar sobre las filas de la columna estado para saber si el compromiso ya fue cargado anteriormente o no, los compromisos cargados deberan tener escrito un "OK" en la columna "ESTADO1"
        IF    '${comprobante}' != 'OK'
        Log    Checking row con el estado
        ELSE
            Continue For Loop If    '${comprobante}' == 'OK'
        Log    Skipping row with "OK"
        END 

          #Si los numeros de cuenta del excel compromiso y factura aysa coinciden se ejecuta el proximo row  
        IF    ${n_cuenta3} == ${n_cuenta2}          
            FOR    ${row}    IN    @{data_as_table}              
                ${cuenta} =    Set Variable    ${row["NUMERO_DE_CTA"]}

                #Si los numeros de cuenta del excel compromiso y factura aysa y matriz central coinciden se ejecuta el proximo If  
                IF    ${n_cuenta3}==${cuenta}
                    Log    datos coinciden: ${n_cuenta3}

                    #Seleccionar ventana de nuevo comprobante
                    RPA.Windows.Click    id:43    timeout=10
                    Sleep    0.5s
                    
                    #cargar proveedor tipo en estos casos es (12)
                    ${provetipo} =    Set Variable    ${row["PROVE_TIPO"]}
                    Send Keys    id:10    ${provetipo}  

                    #Cargar numero prove tipo aysa = 120196
                    ${numerotipo} =    Set Variable    ${row["NUMERO"]}
                    Send Keys    id:11    ${numerotipo}

                    #Crea variable para tipo Factura normalmente es tipo 45
                    ${tipofb}    Set Variable    ${row2["TIPOFB"]}
                    Send Keys    keys={ENTER}
                    Sleep    0.5s  

                    #Borra lo que esta escrito antes de cargar el tipo de factura 
                    Send Keys     keys={DELETE}
                    Sleep    0.5s
                    Send Keys    keys={DELETE}

                    #Carga el tipo de Factura
                    Send Keys    id:7    ${tipofb}

                    #Cargar Punto venta
                    ${pv} =    Set Variable    ${row2["Punto de Venta"]}
                    Send Keys    id:6    ${pv}

                    #cargar el numero de la Factura
                    ${factura}    Set Variable    ${row2["N° de Factura"]}
                    Send Keys    id:12    ${factura}

                    #Conseguir la fecha actual y ordenarla de manera eficiente para continuar con la carga
                    ${fecha_actual} =    Get Current Date
                    ${fecha_formateada} =    Convert Date    ${fecha_actual}    %d/%m/%Y
                    Log    La fecha actual es: ${fecha_formateada}

                    #Ir a la pestaña de fecha de emision haciendo click en la fecha actual 
                    RPA.Windows.Click    ${fecha_formateada} 

                    #Crear variables para carga de fecha
                    ${fecha} =    Set Variable    ${row2["Fecha de Vencimiento"]}
                    @{fecha_parts} =    Split String    ${fecha}    /
                    ${day} =    Convert To Integer    ${fecha_parts}[0]
                    ${month} =    Convert To Integer    ${fecha_parts}[1]
                    ${year} =    Convert To Integer    ${fecha_parts}[2]

                    #Cargar fecha de emision
                    Send Keys    keys=${year}{RIGHT}
                    Send Keys    keys=${day}{RIGHT}
                    Send Keys    keys=${month}{ENTER}

                    #Cargar fecha de vencimiento 
                    Send Keys    keys=${day}{RIGHT}
                    Send Keys    keys=${month}{RIGHT}
                    Send Keys    keys=${year} {RIGHT} {ENTER}

                    #Cargar Importe de la factura        
                    ${importe} =    Set Variable    ${row2["Total a Pagar"]}
                    ${numero_sin_puntos} =    Set Variable    ${importe.replace('.', '')}
                    ${importe_final} =    Set Variable    ${numero_sin_puntos.replace(',', '.')}
                    Send Keys    id:30    ${importe_final}
                    Log    datos de comprobante cargados

                    #Apretar click en la ventana de Aceptar
                    RPA.Windows.Click    id:45    timeout=30
                    Sleep    1.5s

                    #Aceptar cartel de correlativa de comprobantes
                    ${elemento_existente} =        Run Keyword And Return Status    RPA.Windows.Click    locator=id:6    timeout=10
                    Run Keyword If    ${elemento_existente}    Log    Se acepto la correlatividad de comrpobantes 
                    Sleep    1.5s

                    #Apretar click en el cartel de que ya existe la carga de esa factura y aceptar
                    ${elemento_existente2} =    Convert To String    id:65535    
                    ${result_status} =    Run Keyword And Return Status    ${elemento_existente2}
                    Run Keyword If    '${result_status}'=='True'    ${texto_del_cartel}= Get Text    ${elemento_existente2}
                    ${result} =    Run Keyword And Return Status    'existe' in ${texto_del_cartel.lower()}
                    Run Keyword If    ${result}    Log    Apareció el cartel de que la factura existe
                    ...    ELSE    Send Keys    keys={ENTER}
                    
                    #Cargar Ok en el excel de facturasaysa
                    Open Workbook    ${excel_file2}
                    ${numerofila3} =    Set Variable    ${row2["ORDEN1"]}
                    ${numerofila2} =    Convert To Integer    ${numerofila3}
                    Set Cell Value    ${numerofila2}    ${column_name1}    ${value_to_write}
                    Log    Se cambió el valor de la celda a OK
                    Save Workbook   
                    Sleep    3s  
                    Close Workbook
                    
                    #Cargar Ok en el excel de Comprobantes
                    Open Workbook    ${excel_file3}
                    ${numerofila} =    Set Variable    ${row3["ORDEN"]}
                    ${numerofila1} =    Convert To Integer    ${numerofila}
                    Set Cell Value    ${numerofila}    ${column_name}    ${value_to_write}
                    Log    Se cambió el valor de la celda a OK
                    Save Workbook   
                    Close Workbook

                    #Si la carga de la factura existe apretar cancelar para continuar buscando la siguiente factura 
                    ${elemento_existente6} =    Run Keyword And Return Status    RPA.Windows.Click    id:44

                    #Conseguir como elemento la fecha actual, la cual aparece en la ventana para relacionar el 16 (afectacion varia)                 
                        ${element} =    Run Keyword And Return Status    RPA.Windows.Get Element    ${fecha_formateada}
                        
                        #Si la fecha esta visible apretar en la fecha 
                        ${element1} =    Run Keyword If   ${element}    RPA.Windows.Click    ${fecha_formateada}
                        IF   ${element}==True
                        
                        #Si la fecha esta visible apretar tab y enter para ir a la pestaña de carga de 16
                        Send Keys     keys={TAB}
                        Sleep     0.5s
                        Send Keys     keys={ENTER}
                        Sleep     3s
                        
                        # Cargar Tipo de documento ya sea 15 0 16, borrando antes lo escrito.
                        ${tipo3} =     Set Variable     ${row3["Tipo_comprobante"]}
                        ${elemento_encontrado} =     Run Keyword And Return Status     RPA.Windows.Click     id:11
                        Send Keys     keys={DELETE}
                        Send Keys     keys=${tipo3}

                        # Cargar numero de la afectacion varia (16), borrando antes lo escrito                        
                        ${num3} =     Set Variable     ${row3["Numero_comprobante"]}
                        ${elemento_encontrado} =     Run Keyword And Return Status     RPA.Windows.Click     id:6
                        Send Keys     keys={DELETE}
                        Send Keys     keys=${num3}

                        #Seleccionar la pestaña de ejecutar busqueda para continuar con la relacion.
                        ${elemento_encontrado} =     Run Keyword And Return Status     RPA.Windows.Click     id:4
                        Log     Se cargo correctamente                       

                        #Seleccionar la afectacion varia 
                        Sleep    3s
                        Send Keys    keys={TAB}{DOWN}
                        Send Keys    keys={ENTER}
                        Sleep    3s

                        #Seleccionar cartel de aceptar
                        RPA.Windows.Click    id:11

                        #Salir de compromisos
                        RPA.Windows.Click    name:Salir

                        #Ir a transacciones
                        RPA.Windows.Click    name:Transacciones    timeout=60

                        ## ir a Devengado
                        RPA.Windows.Click    name:Devengado    timeout=30

                        # Ir a Devengado 2
                        RPA.Windows.Click    id:104    timeout=30

                        #Seleccionar Nuevo
                        RPA.Windows.Click    id:22    timeout=10

                        #cargar proveedor tipo
                        Send Keys    keys={ENTER}
                        Send Keys    id:37    ${provetipo}

                        #Cargar numero prove tipo
                        Send Keys    id:38    ${numerotipo}

                        #Ir hasta la pestaña aplicar
                        Send Keys    keys={TAB 6}
                        Send Keys    keys={ENTER}

                        #Cargar tipo
                        Send Keys    id:11    ${tipo3}
                        
                        #Cargar numero del 16
                        Send Keys    id:6    ${num3}

                        #Ejecutar busqueda
                        Send Keys    keys={TAB 2}
                        Send Keys    keys={ENTER}

                        #Seleccionar 16
                        Send Keys    keys={TAB}{DOWN}
                        Send Keys    keys={ENTER}
                        Sleep    3s

                        #Clickear la ventana de aceptar
                        RPA.Windows.Click    id:23    timeout=10
                        Sleep    1.5s

                        #Cargar los OK en la columna "Devengados"
                        Open Workbook    ${excel_file2}
                        ${numerofila3} =    Set Variable    ${row2["ORDEN1"]}
                        ${numerofila2} =    Convert To Integer    ${numerofila3}
                        Set Cell Value    ${numerofila2}    ${column_name2}    ${value_to_write}
                        Log    Se cambió el valor de la celda a OK
                        Save Workbook   
                        Sleep    3s  
                        Close Workbook
                
                        #Ir a la ventana de observacion 
                        RPA.Windows.Click    id:48    timeout=10
                        Send Keys    keys={RIGHT 3}

                        #Editar la observacion 
                        RPA.Windows.Click    id:45
                        Send Keys    keys=NUMERO_DE_CUENTA:${cuenta} {ENTER}
                        ${dire}    Set Variable    ${row["DIRECCION"]}
                        Send Keys    keys=DIRECCION:${dire}

                        #Aceptar la observacion
                        RPA.Windows.Click    id:43
                        Sleep    1.5s

                        #Volver a la pestaña de datos
                        Send Keys    keys={ALT}
                        RPA.Windows.Click    id:48
                        Send Keys    keys={RIGHT}
                        Send Keys    keys={LEFT}

                        #Clickear la ventana imprimir
                        RPA.Windows.Click    id:19    timeout=10

                        #Imprimir como pdf 
                        RPA.Windows.Click    id:1001    timeout=10
                        RPA.Windows.Click    id:10    timeout=10
                        Sleep    15s

                        #Borra el nombre que viene por defecto en el pdf el cual es "Crystal Reports"
                        RPA.Windows.Double Click    id:1148    timeout=160
                        Send Keys    keys={DEL}
                        RPA.Windows.Double Click    id:1148    timeout=30
                        Send Keys    keys={DEL}
                        Sleep    0.5s

                        #Cargar el nombre del PDF y la ruta, en este caso le pondremos como nombre el numero del 16 y un numero del cual es la iteracion por la que va 
                        ${contador} =    Convert To Integer    ${contador}
                        ${contador} =    Evaluate    ${contador} + 1
                        ${numero_de_afectacion} =    Set Variable    ${num3}_(${contador})
                        ${fecha_hoy} =    Get Current Date
                        ${año} =    Convert Date    ${fecha_hoy}    %Y
                        ${mes} =    Convert Date    ${fecha_hoy}    %m
                        ${día} =    Convert Date    ${fecha_hoy}    %d

                        # Ruta completa de la carpeta
                        ${ruta_año}    Set Variable    ${ruta_base}\\${año}
                        ${ruta_mes}    Set Variable    ${ruta_año}\\${mes}
                        ${ruta_dia}    Set Variable    ${ruta_mes}\\${día}
                        Send Keys    keys=C:\\Users\\zcheveste\\Documents\\${año}\\${mes}\\${día}\\${nombre_carpeta}\\BOT_${numero_de_afectacion}.pdf
                        Sleep    3s

                        #Guardar archivo PDF
                        Send Keys    keys={ENTER}

                        # Una vez guardado el PDF se abrira este mismo y procedemos a cerrar la ventana del PDF que ya ha sido guardado 
                        RPA.Windows.Click    name:AVPageView    timeout=30
                        Send Keys    keys={CTRL}{Q}

                        #Salir de la pestaña devengados
                        RPA.Windows.Click    id:18

                        END
                        Sleep    3s
                        END
                    END        
                END
            END
        END
     Close Workbook