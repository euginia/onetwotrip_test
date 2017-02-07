#ассоциативный массив для приведения строки со временем к типу Time
$months = {January: 1, February: 2, March: 3, April: 4, May: 5, June: 6, July: 7, August: 8, September: 9, October: 10, November: 11, December: 12}

#приведение строки в объект типа Time
def time_transp(str_time)
    str_time = str_time.gsub('/',' ')
    str_time = str_time.gsub(':',' ')
    array_time = str_time.split
    msg_time = Time.new(array_time[2], $months[array_time[1].to_sym], array_time[0], array_time[3], array_time[4], array_time[5], array_time[6].insert(3,':'))
    return msg_time
end

#Проверка давности сообщения
def time_check(now_time, msg_time)
    if now_time.to_f - msg_time.to_f <= 24 * 60 * 60
        return true
    end
    return false
end

#Вывод результатов
def puts_final(status_array, count200, count_non_200, resp_time_sum)
    puts count_non_200.to_s + ' of ' + (count200 + count_non_200).to_s + ' returned non 200 code.'    
    status_array.each{|key, value| print key, " - ", value, "\n" }
    puts "Average response with 200 code: " + (resp_time_sum / count200).round.to_s + 'ms from ' + count200.to_s + ' requests.'    
end



#задаем регулярное выражение для вычленения времени
time_stamp = /(\d){1,2}\/(\w){1,}\/(\d){4}:(\d){2}:(\d){2}:(\d){2} \+(\d){4}/

#задаем регулярные выражения для вычленения из строки нужной подстроки, затем чисел
up_status = /up_status="(\d){3}"/
x_resp_time = /x_resp_time="(\d){1,}\.(\d){2}ms"/
status = /(\d){3}/
resp_time = /(\d){1,}\.(\d){2}/

#создаем ассоциативный массив, инициализируем значение с новым ключом как 0; ключом будет являться код, значением - количество повторений в логе
status_array = Hash.new{|h,k| h[k] = 0}

#счетчик количества записей с кодом 200
count200 = 0
#счетчик количества записей с кодом не 200
count_non_200 = 0
#счетчик для суммы времени ответа, чтобы потом посчитать среднее
resp_time_sum = 0

#открываем файл
log_file = File.new("nginx.txt")

#считываем файл построчно
log_file.each do |line|
    str_time = line.slice(time_stamp)                          #вырезаем время сообщения
    msg_time = time_transp(str_time)
    #now_time = Time.now - дата уже сильно не подходящая
    now_time = Time.new(2016, 5, 19, nil, nil, nil, "+03:00")
    
    if time_check(now_time, msg_time)
        str_status = line.slice(up_status)                     #вырезаем кусок с up_status
        str_resp_time = line.slice(x_resp_time)                #вырезаем кусок с x_resp_time
    
        key = str_status.slice(status).to_i                    #вырезаем код, приводим его к числовому типу
        time_value = str_resp_time.slice(resp_time).to_f       #вырезаем время, приводим его к числовому типу
    
        #в зависимости от значения кода делаем следующее
        if (key == 200)
            count200 = count200.next                           #если код 200, то увеличиваем счетчик на 1
            resp_time_sum += time_value                        #и прибавляем к имеющейся сумме новое значение времени ответа
        else
            count_non_200 = count_non_200.next
            status_array[key] = status_array[key].next         #в противном случае увеличиваем значение соответствующего элемента ассоц массива
        end
    end
end

#закрываем файл
log_file.close

puts_final(status_array, count200, count_non_200, resp_time_sum)