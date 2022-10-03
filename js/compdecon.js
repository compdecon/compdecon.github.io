function toggleSign(flag) {
    // ID="sign"
    // 1 = Open:
    // "./images/Open-sign.png"
    // 0 = Closed:
    // "./images/Closed-sign.png"
    if(flag) {
        document.getElementById("sign").src   = "./images/Open-sign.png";
        document.getElementById("sign").alt   = "Open for business";
        document.getElementById("sign").title = "Open for business";
    } else {
        document.getElementById("sign").src   = "./images/Closed-sign.png";
        document.getElementById("sign").alt   = "Closed for the day";
        document.getElementById("sign").title = "Closed for the day";
    }
}

function updateMsg(myId, msg) {
    // Should cover an empty message and a '.' message
    if(msg && msg !== ".") {
        document.getElementById(myId).innerHTML = '<p>' + msg + '</p>';
    } else {
        document.getElementById(myId).innerHTML = '';
    }
}

function updateBlog(myId, msg) {
    // Should cover an empty message and a '.' message
    if(msg && msg !== ".") {
        document.getElementById(myId).innerHTML = msg;
    } else {
        document.getElementById(myId).innerHTML = '';
    }
}

function lastUpdated(lastchange) {
    if(typeof lastchange != "number") {
        lastchange = -1;
    }
    document.getElementById("lastUpdateOn").innerHTML = 'UPDATED: <span class="myH1z">(' + new Date(lastchange*1000) + ')</span>';
}

lastUpdate = '';
function currentWeather(weather) {
    /*
      "weather": {
      "number": 1,
      "name": "Tonight",
      "startTime": "2021-06-25T21:00:00-04:00",
      "endTime": "2021-06-26T06:00:00-04:00",
      "isDaytime": false,
      "temperature": 67,
      "temperatureUnit": "F",
      "temperatureTrend": null,
      "windSpeed": "5 to 10 mph",
      "windDirection": "S",
      "icon": "https://api.weather.gov/icons/land/night/bkn?size=medium",
      "shortForecast": "Mostly Cloudy",
      "detailedForecast": "Mostly cloudy, with a low around 67. South wind 5 to 10 mph."
      },
    */
    if(lastUpdate != weather.startTime) {
        lastUpdate = weather.startTime;
        icon = icon.replace('medium', 'small');
        if(debug) console.log("URL=" + weather.icon);
        document.getElementById("weatherDiv").innerHTML = '<div class="table-responsive"><table class="table"><tr><td width="20%" height="auto"><img width="100%" height="auto" src="' + weather.icon + '" alt="" width="20%" height="auto"></td><td style="font-size: 120%">' + weather.detailedForecast + '(' + weather.startTime + ')' + '</td></tr></table>';
    } 
}

function currentSpaceWeather(weather) {
    /*
      space_weather is a JSON array of string that are preformated

      "space_weather": [
      "Space Weather Message Code: WARK04\r\nSerial Number: 4006\r\nIssue Time: 2022 Jan 24 2127 UTC\r\n\r\nWARNING: Geomagnetic K-index of 4 expected\r\nValid From: 2022 Jan 24 2125 UTC\r\nValid To: 2022 Jan 25 0000 UTC\r\nWarning Condition: Onset\r\n\r\nNOAA Space Weather Scale descriptions can be found at\r\nwww.swpc.noaa.gov/noaa-scales-explanation\r\n\r\nPotential Impacts: Area of impact primarily poleward of 65 degrees Geomagnetic Latitude.\r\nInduced Currents - Weak power grid fluctuations can occur.\r\nAurora - Aurora may be visible at high latitudes such as Canada and Alaska.",
      "Space Weather Message Code: ALTEF3\r\nSerial Number: 3193\r\nIssue Time: 2022 Jan 24 0503 UTC\r\n\r\nCONTINUED ALERT: Electron 2MeV Integral Flux exceeded 1000pfu\r\nContinuation of Serial Number: 3192\r\nBegin Time: 2022 Jan 16 1445 UTC\r\nYesterday Maximum 2MeV Flux: 6126 pfu\r\n\r\nNOAA Space Weather Scale descriptions can be found at\r\nwww.swpc.noaa.gov/noaa-scales-explanation\r\n\r\nPotential Impacts: Satellite systems may experience significant charging resulting in increased risk to satellite systems."
      ],
      
      Perhaps we can stick each string into a div with pre
    */
    // a = s.split(/(www.*?)$/m)
    // s.replace(a[1], "<a href=\"" + a[1] + "\">" + a[1] + "</a>")
    if(Array.isArray(weather)) {
        document.getElementById("space_weatherDiv").innerHTML = '  <span class="myH1">Current Space Weather at CDL</span><div id="space_weatherDivA" style="border: thick double; padding-left:0.5em;"></div>';

        var i = 1;
        weather.forEach(el => {
            var a = el.split(/(www.*?)$/m); // m - multiline
            var divElement = document.getElementById("space_weatherDivA");
            divElement.innerHTML += '<div><pre>' + el.replace(a[1], "<a href=\"https://" + a[1] + "/\" rel=\"noreferrer\" target=\"_blank\">" + a[1] + "</a>") + '</pre></div>';
            if(i < weather.length) {
                divElement.innerHTML +=  '<hr>';
                i++;
            }
        });
        if(debug) console.log("i = " + i + "\nL = " + weather.length);

    } else {
        // debug message
        if(debug) console.log(Date.now() + ": No Spacey weather");
    }
}

/*
  Informational responses (100-199)
  Successful responses    (200-299)
  Redirection messages    (300-399)
  Client error responses  (400-499)
  Server error responses  (500-599)

  https://learnwithparam.com/blog/how-to-handle-fetch-errors/

  Error handling in fetch API using promises (no link)

  We can rectify it by throwing error and allow only response which has status code between 200 and 299.

  This will fix the problem, you can even extract out the checking status part as a function which returns a promise or throw error.

  if (response.status >= 200 && response.status <= 299) {
    return response.json();
  } else {
    throw Error(response.statusText);
  }

  https://stackoverflow.com/questions/38235715/fetch-reject-promise-and-catch-the-error-if-status-is-not-ok

  Fetch promises only reject with a TypeError when a network error occurs. Since 4xx and 5xx responses aren't network errors, there's nothing to catch. You'll need to throw an error yourself to use Promise#catch.

  A fetch Response conveniently supplies an ok , which tells you whether the request succeeded. Something like this should do the trick:

  fetch(url).then((response) => {
    if (response.ok) {
      return response.json();
    }
    throw new Error('Something went wrong');
  })
  .then((responseJson) => {
    // Do something with the response
  })
  .catch((error) => {
    console.log(error)
  });
*/
function getStatus(url) {
    // https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch
    fetch(url, { 
        method: 'GET'
    })
    .then(function(response) {
        if (response.status >= 200 && response.status <= 299) {
            return response.json();
        } else {
            throw Error(response.statusText);
        }
        //return response.json();
    })
    .then(function(json) {
        // use the json
        if(debug) console.log(Date);
        toggleSign(json.state.open);

        updateMsg("preUpdateDiv",  json.state.preMessage);
        updateMsg("updateDiv",     json.state.message);
        updateMsg("postUpdateDiv", json.state.postMessage);
        updateBlog("blogUpdate",   json.state.blogUpdate);

        lastUpdated(json.state.lastchange)
        currentWeather(json.ext_weather);
        currentSpaceWeather(json.space_weather);
    })
    .catch(error => {
        console.log(Date() + 'Fetch error:', error);
    });
}

/*
  function myFunction() {
  document.getElementById("myAnchor").href = "http://www.cnn.com/";
  // document.getElementById("demo").innerHTML = "The link above now goes to www.cnn.com.";
  }
* 
function setSeason() {
    // Need to do the math here
    // and this just got more complicated
    //            <img srcset="images/CDL-front-laptop.jpg 1024w,
    //                     images/CDL-front-tablet.jpg 768w,
    //                   images/CDL-front-modelL.jpg 430w,
    //                   images/CDL-front-modelM.jpg 379w,
    //                   images/CDL-front-modelS.jpg 328w"
    //           sizes="(max-width: 1024px) 768px 430px 379px 328px"
    //           src="images/CDL-front-laptop.jpg"
    //           alt="Picture of CDL Lab"
    //           title="Picture of CDL Lab"
    //           id="frontDoorImg">
    var seasonal = [
        {
            "href":    "images/CDL-front.jpg",
            "img":     "images/CDL-front.jpg",
            "title":   "CDL/IXR front door at night",
            "comment": "default image"
        },
        {
            "href":    "",
            "img":     "",
            "title":   "",
            "comment": "Winter"
        },
        {
            "href":    "",
            "img":     "",
            "title":   "",
            "comment": "Spring"
        },
        {
            "href":    "",
            "img":     "",
            "title":   "",
            "comment": "Summer"
        },
        {
            "href":    "",
            "img":     "",
            "title":   "",
            "comment": "Fall"
        },
        {
            "href":    "",
            "img":     "",
            "title":   "",
            "comment": "Special 1"
        },
        {
            "href":    "",
            "img":     "",
            "title":   "",
            "comment": "Special 2"
        },
        {
            "href":    "",
            "img":     "",
            "title":   "",
            "comment": "Special 3"
        },
        {}
    ];

    // Figure out the 'season' so we can put an appropriate picture of the front
    // of the CDL.
    // 0 = default
    // 1 = Winter (Jan, Feb, Mar)
    // 2 = Spring (Apr, May, Jun)
    // 3 = Summer (Jul, Aug, Sep)
    // 4 = Fall   (Oct, Nov, Dev)
    
    // href tag
    document.getElementById("frontDoorHref").href = seasonal[0].href;

    // img tag
    document.getElementById("frontDoorHref").src  = seasonal[0].img;
    document.getElementById("frontDoorImg").title = seasonal[0].title;
}
/* */

function toggleDiv() {
    var x = document.getElementById("space_weatherDiv");
    var b = document.getElementById("spaceButton");
    var o = document.getElementById("spaceOuter");

    if (x.style.display === "none") {
        if(debug) console.log("Show");
        x.style.display = "block";
        b.src = "./images/more.jpg";
        o.style.border = 0;
    } else {
        if(debug) console.log("Hide");
        x.style.display = "none";
        b.src = "./images/less.jpg";
        o.style.border = "thick double";
    }
}

// =====================================================================================

const queryString = window.location.search;
//console.log(queryString);

const urlParams = new URLSearchParams(queryString);

if(urlParams.has('debug')) {
    debug = true;
    tOut =  10000; // 10 seconds
} else {
    debug = false;
    tOut = 300000; // 300 seconds, 5 minutes
}
// This handles my weather stuff and hopefully adapted to deal with the sprinkler sysem
var url = "./status.json";

//setSeason(); // Set the correct season image of the CDL front door.

// Toggle Space Weather off
document.getElementById("space_weatherDiv").style.display = "block";
document.getElementById("spaceButton").src = "./images/more.jpg";
toggleDiv();

window.onload = function() {
    //
    // Need to check for really old browsers that may not have fetch
    // support for VCF and Vintage computers
    //
    //xmlHttpGet(url);
    //setInterval("xmlHttpGet(url)", 10000); // Prod set to minutes, not seconds?
    getStatus(url);
    setInterval("getStatus(url)", tOut); // Prod set to appropriate minutes, not seconds?
}
