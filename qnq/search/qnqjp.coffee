###
	https://spreadsheets.google.com/feeds/worksheets/{SHEET-ID}/public/basic?alt=json       get grid ids
	https://spreadsheets.google.com/feeds/list/{SHEET-ID}/{GRID-ID}/public/values?alt=json  get whole sheet data
	https://spreadsheets.google.com/feeds/cells/{SHEET-ID}/{GRID-ID}/public/values          get all cell data
	alt=json                                                                                return json
	alt=json-in-script&callback={CALLBACK}                                                  return data to callback function
	
	https://spreadsheets.google.com/feeds/worksheets/1wzAwAH4rJ72Zw6r-bjoUujfS5SMOEr38s99NxKmNk4g/public/basic?alt=json
	###
	
	Setting =
	    localStorage: false
	    cache:
	        adLoading: "0"
	        searchMinLength: "1"
	        searchMaxResult: "25"
	        searchTypeControl: "no"
	        searchType: []
	
	    init: ->
	        Setting.localStorage = Setting.localStorageSupport()
	        if Setting.localStorage
	            localSetting = localStorage.getItem("qnqjpSetting")
	        else
	            localSetting = util.getCookie("qnqjpSetting")
	
	        Setting.cache = $.extend({}, Setting.cache, JSON.parse(localSetting))
	
	        for own key, result of Setting.cache
	            $('.' + key ).val(result)
	
	        if Setting.get("searchTypeControl") != "no" && Setting.get("searchType") != []
	            $(".from-source").val( Setting.get("searchType") ).change()
	        else
	            Setting.cache['searchType'] = [Setting.defaulttype]
	            $(".from-source").val( Setting.get("searchType") ).change()
	
	        if Setting.get("adLoading") != "1"
	            $("#overlay-loading-ad").remove()
	
	    get: (key) ->
	        Setting.cache[key]
	
	    save: (json)->
	        localSetting = {}
	        for v,k in json
	            localSetting[v.name] = v.value
	
	        localSetting = Setting.cache = $.extend({}, Setting.cache, localSetting)
	
	        if Setting.localStorage == true
	            localStorage.setItem("qnqjpSetting", JSON.stringify(localSetting))
	        else
	            util.setCookie("qnqjpSetting", JSON.stringify(localSetting), "")
	
	    localStorageSupport: ->
	        try
	            localStorage.setItem("test", "test")
	            localStorage.removeItem("test")
	            return true
	        catch e
	            return false
	
	        return
	
	
	
	class qnqjpLoader
	#    @data =
	#        classify: []
	#        fill: []
	#        normal: []
	#        sort: []
	#        daily: []
	    @data =
	         db : TAFFY()
	
	    @loadCount = 0
	
	    @option =
	        excelIds:
	            classify:
	                sheedId: "1lN5FAdZxu8rcZau2x7Nm0nx_hnMvzMqKdl1TYGdQ2yM" # 多綠: "1hccBm0JPSuZgG472UML7NglUETlzkyV8zC3muI-d_TY"
	                gridId:  "oxjzy1p" # 多綠: "oymg4yh"
	            ox:
	                sheedId: "1S1LtmvHIs5U2Cr_5H5IdxMKvaGHsNd4pez3KIa-Q2_g"
	                gridId:  "o1gtjce"
	#        loadCount: 0
	
	    @addScript: (entry) ->
	        src = "https://spreadsheets.google.com/feeds/cells/#{entry.sheedId}/#{entry.gridId}/public/values?alt=json-in-script&callback=qnqjpLoader.load"
			s = document.createElement( 'script' )
	        s.setAttribute( 'src', src )
	        document.body.appendChild( s )
	
	    @load: (data) ->
	        tmp = data.feed.id.$t.split('/')
	        if tmp.length == 9
	#            if tmp[6] == 'oskx7l9'
	#                return @_loadSort (data.feed.entry)
	#            if tmp[6] == 'or1iuun'
	#                return @_loadDaily (data.feed.entry)
	            if tmp[6] == 'oxjzy1p'
	                return @_loadNormal ([data.feed.entry, '一般題'])
	
	            return @_loadNormal ([data.feed.entry, 'OX題'])
	
	    @_loadNormal: (indata) ->
	        data = indata[0]
	        name = indata[1]
	        tmp = {}
	        col = 0
	        keys = ['','','question','answer']
	        db = []
	        for index, entry of data
	            if (parseInt(entry.gs$cell.row) <= 1 )
	                continue
	
	            col = parseInt(entry.gs$cell.col)
	
	            if col >= 1 && col <= 3
	
	                if col == 1
	                    tmp = {}
	
	                tmp[keys[col]] = entry.content.$t
	
	                if col == 3
	                    if name == '一般題'
	                        tmp['type'] = '一般題'
	                    if name == 'OX題'
	                        tmp['type'] = 'OX題'
	                    tmp['fulltext'] = "#{tmp['question']}#{tmp['answer']}".toLowerCase()
	                    db.push(tmp)
	        qnqjpLoader.data.db.insert(db)
	        return @_loadComplete()
	#    @_loadSort: (data) ->
	#        tmp = []
	#        col = 0
	#        for index, entry of data
	#            if (parseInt(entry.gs$cell.row) <= 2 )
	#                continue;
	#            col = parseInt(entry.gs$cell.col)
	#            if ( col >= 2 && col <= 6 )
	#                    if (col == 2)
	#                        tmp = []
	#                    tmp.push(entry.content.$t)
	#                    if (col == 6)
	#                        @data.sort.push(tmp)
	#
	#        return @_loadComplete()
	#
	#    @_loadDaily: (data) ->
	#        # 2 url, 4 quesiton, 5 answer
	#        tmp = []
	#        col = 0
	#        for index, entry of data
	#            if (parseInt(entry.gs$cell.row) <= 2 )
	#                continue;
	#            col = parseInt(entry.gs$cell.col)
	#            if col == 3
	#                continue
	#
	#            if col >= 2 && col <= 5
	#                if col == 2
	#                    tmp = [];
	#                tmp.push(entry.content.$t)
	#                if (col == 5)
	#                    @data.daily.push(tmp)
	#
	#        return @_loadComplete()
	
	    @_loadComplete: () ->
	        @loadCount++
	        if @loadCount == Object.keys(@option.excelIds).length
	            $("#overlay-loading").remove();
	            $("#load-count").text('共讀取了 ' + @data.db().count() + ' 個問題。');
	            $("#result-limit").html("<span class='hidden-xs'>僅顯示</span>前 <a href='#' data-toggle='modal' data-target='#setting-modal'>#{Setting.get('searchMaxResult')} </a>個<span class='hidden-xs'>結果</span>。")
	        else
	            $("#loaded-count").text(@loadCount + '/' + Object.keys(@option.excelIds).length);
	        return
	    @htmlEncode: ( html ) ->
	        return document.createElement( 'a' ).appendChild(document.createTextNode( html ) ).parentNode.innerHTML
	
	    @highlight: ( keyword, msg) ->
	        if Array.isArray(keyword)
	            for kw in keyword
	                msg = msg.split(kw).join("<strong>#{kw}</strong>")
	        else
	            msg = msg.split(keyword).join("<strong>#{keyword}</strong>")
	        return msg
	
	    @_initEvent: () ->
	        $(".form").submit (e) ->
	            e.preventDefault()
	            false
	
	        $(".from-source").on "change", ->
	            if Setting.get('searchTypeControl') != 'no'
	                type = $(".from-source:checked").map () ->
	                    return this.value
	                .get()
	                Setting.save([{ name:'searchType', value:type }])
	            $("#inputKeyword").trigger "keyup"
	
	        $("#result").on "click", ".btn-more", ->
	            tr = $(this).parents("tr")
	            type = tr.data("type");
	            pos = tr.data("pos");
	            trOffset = tr.offset();
	            data = {}
	            text = ''
	#            if type == 'normal'
	#                data = qnqjpLoader.data[type][pos]
	#                text = "題目顏色：#{data.color}，題目類型：#{data.type}，"
	#            else if type == 'daily'
	#                data =
	#                    question: "#{qnqjpLoader.data[type][pos][1]}，網址：#{qnqjpLoader.data[type][pos][0]}"
	#                    answer: qnqjpLoader.data[type][pos][2]
	#            else
	#                data =
	#                    question: qnqjpLoader.data[type][pos][0]
	#                    answer: qnqjpLoader.data[type][pos].slice(1).join('、')
	#
	#            text += "<a id=\"question-report\" href=\"javascript:void\" data-question=\"#{data.question}\" data-answer=\"#{data.answer}\">錯誤回報</a>"
	            text = "沒有什麼好更多的 ㄎㄎ"
	            $("#question-info").css({ top: trOffset.top,left: trOffset.left,width: tr.width(),height: tr.height()}).addClass("active")
	            $("#question-info .info div").html(text)
	
	        $("#question-info").on "click", ".btn-close", ->
	            return $("#question-info").removeClass("active")
	
	        $("#question-info").on "click", "#question-report", ->
	            question = encodeURIComponent($(this).data("question"))
	            answer = encodeURIComponent($(this).data("answer"))
	            url = "https://docs.google.com/forms/d/1GYyqSKOfF2KMkMGfEuKtyE8oZadgTRRj_ZClYZRX2Qc/viewform?entry.699244241=%E9%A1%8C%E7%9B%AE%EF%BC%9A#{question}%0A%E5%8E%9F%E5%A7%8B%E7%AD%94%E6%A1%88%EF%BC%9A#{answer}%0A%E6%AD%A3%E7%A2%BA%E7%AD%94%E6%A1%88%EF%BC%9A";
	            $("#report-modal iframe").attr("src", url)
	            $('#report-modal').modal('show')
	
	        $("#inputKeyword").on "keyup", ->
	            val = $(this).val()
	            val = val.replace(/\s\s+/g, ' ')
	
	            $("#question-info").removeClass("active")
	            $("#result").html("")
	
	            if val.length < Setting.get("searchMinLength")
	                return
	
	            val = val.toLowerCase()
	            type = $(".from-source:checked").map () ->
	                return this.value
	            .get()
	
	            result = null
	            try
	                limit = parseInt(Setting.get("searchMaxResult"), 10)
	                if val.split(" ").length > 1
	                    val = val.split(" ")
	                    #val = val.unique()
	                    #   a = [];
	                    #   for i in [0...this.length]
	                    #       if (a.indexOf(this[i]) == -1)
	                    #           a.push(this[i]);
	                    tmp = []
	                    tmp2 = val
	                    for i in [0...tmp2.length]
	                        if (tmp.indexOf(tmp2[i]) == -1)
	                            tmp.push(tmp2[i])
	                    val = tmp
	
	                    for v,i in val
	                        if (v == "")
	                            delete val[i]
	
	                    result = qnqjpLoader.data.db(() ->
	
	                        if $.inArray(this.type, type) == -1
	                            return false
	
	                        for keyword in val
	                            if (this.fulltext.indexOf(keyword) == -1)
	                                return false
	                        return true
	                    ).limit(limit)
	                else
	                    val = [val]
	                    result = qnqjpLoader.data.db({type: type},{fulltext: {likenocase: val}}).limit(limit)
	            catch
	                return
	
	            html = ""
	
	            result.each (r) ->
	
	                if typeof(r.question) == "undefined"
	                    return true
	
	                if r.type == "一般題"
	                    html += '<tr data-pos="XXD" data-type="' + r.type + '"><td class="td-more"><a href="javascript:void(0);" class="btn-more">更多</a></td><td><div class="question">' + qnqjpLoader.highlight(val, r.question) + '</div><div class="text-danger">' + qnqjpLoader.htmlEncode(r.answer).replace(/\n/, "<br />") + '</div></td></tr>'
	
	                else if r.type == "連連看"
	                    html += '<tr data-pos="XXD" data-type="' + r.type + '"><td class="td-more"><a href="javascript:void(0);" class="btn-more">更多</a></td><td><div class="question">' + qnqjpLoader.highlight(val, r.question) + '</div><div class="text-danger">' + qnqjpLoader.htmlEncode(r.answer).replace(/、/g, "<br />") + '</div></td></tr>'
	
	                else
	                    html += '<tr data-pos="XXD" data-type="' + r.type + '"><td class="td-more"><a href="javascript:void(0);" class="btn-more">更多</a></td><td><div class="question">' + qnqjpLoader.highlight(val, r.question) + '</div><div class="text-danger">' + qnqjpLoader.htmlEncode(r.answer) + '</div></td></tr>'
	#                if r.type == "四選一"
	#
	#                    html += '<tr data-pos="' + r.id + '" data-type="' + r.type + '"><td class="td-more"><a href="javascript:void(0);" class="btn-more">更多</a></td><td><div class="question">' + qnqjpLoader.highlight(val, r.question) + '</div><div class="text-danger">' + qnqjpLoader.htmlEncode(r.answer) + '</div></td></tr>'
	
	#                else if r.type == "排序"
	#
	#                    html += '<tr data-pos="' + r.id + '" data-type="' + r.type + '"><td class="td-more"><a href="javascript:void(0);" class="btn-more">更多</a></td><td><div class="question">' + util.highlight(val, r.question) + '</div><div class="text-danger">' + util.htmlEncode(r.answer) + '</div></td></tr>'
	#
	#                else
	#                    md5name = CryptoJS.MD5(r.imgname).toString()
	#                    imgurl = "http://vignette#{util.getRandomInt(1,5)}.wikia.nocookie.net/nekoqnqjp/images/#{md5name.charAt(0)}/#{md5name.charAt(0)}#{md5name.charAt(1)}/#{r.imgname}/revision/latest?path-prefix=zh"
	#
	#                    html += '<tr data-pos="' + r.id + '" data-type="' + r.type + '"><td class="td-more"><!--<a href="javascript:void(0);" class="btn-more">更多</a>--></td><td><div class="col-sm-3"><img src="' + imgurl + '" /></div><div class="col-sm-5">' + util.highlight(val, r.question) + '</div><div class="col-sm-4 text-danger">' + util.htmlEncode(r.answer) + '</div></td></tr>'
	
	            $("#result").append(html)
	
	            return
	        
	        $(".list-type, .list-stype, .list-color").on "change", ->
	
	            type = $(".list-type:checked").val()
	            stype = ""
	            color = ""
	            result = qnqjpLoader.data.db({type: type})
	
	            $("#result-list").html("")
	
	            html = ""
	
	            result.each (r) ->
	                if r.type == "分類題"
	                    html += '<tr data-pos="XXD" data-type="' + r.type + '"><td><div class="question">' + r.question + '</div><div class="text-danger">' + qnqjpLoader.htmlEncode(r.answer).replace(/\n/, "<br />") + '</div></td></tr>'
	
	                else if r.type == "連連看"
	                    html += '<tr data-pos="XXD" data-type="' + r.type + '"><td><div class="question">' + r.question + '</div><div class="text-danger">' + qnqjpLoader.htmlEncode(r.answer).replace(/、/g, "<br />") + '</div></td></tr>'
	
	                else
	                    html += '<tr data-pos="XXD" data-type="' + r.type + '"><td><div class="question">' + r.question + '</div><div class="text-danger">' + qnqjpLoader.htmlEncode(r.answer) + '</div></td></tr>'
	
	
	            $("#result-list").append(html)
	
	            return
	
	        return
	
	    @init: () ->
	        for type, entry of @option.excelIds
	            @addScript (entry)
	        @_initEvent()
	        return
	    $("#form-setting").on "submit", (e) ->
	        e.preventDefault()
	        type = $(".from-source:checked").map () ->
	            return this.value
	        .get()
	        formArray = $("#form-setting").serializeArray()
	        formArray.push({ name:'searchType', value:type })
	        Setting.save(formArray)
	        $('#setting-modal').modal('hide')
	        $("#result-limit").html("<span class='hidden-xs'>僅顯示</span>前 <a href='#' data-toggle='modal' data-target='#setting-modal'>#{Setting.get('searchMaxResult')} </a>個<span class='hidden-xs'>結果</span>。")
	        return false
	
	$ ->
	    Setting.init()

