var L // Locales
var app = function() {
    let debug = false;
    var bgSound = new Audio(`https://cfx-nui-exp_hack/client/ui/sounds/background.mp3`)
    bgSound.volume = 0.05
    let hOptions = 4,
        vOptions = 4,
        currentPosition = 0,
        correctSelections = 0,
        attempts = 0,
        currentOptions = [],
        countdown = 10,
        counterObj = null,
        rounds = 2,
        curRound = 1;
    return {
        init: () => {
            window.addEventListener('message', function(event) {
                let wrap = document.querySelector('.hack-wrap');
                if (event.data.type == "enableui") {
                    rounds = event.data.params.rounds || 2
                    hOptions = event.data.params.squares || 4
                    vOptions = event.data.params.squares || 4
                    wrap.classList.remove("hide");
                    this.setTimeout(function() {
                        app.generateGrid();
                        bgSound.play()
                    }, 700)
                }
                if (event.data.type == "closeui") {
                    wrap.classList.add("hide");
                    app.resetToDefault();
                    bgSound.pause()
                }
                if (event.data.type == "death") {
                    app.sendResult(false);
                }
            });
        },
        resetToDefault: () => {
            hOptions = 4;
            vOptions = 4;
            curRound = 1;
            currentPosition = 0;
            correctSelections = 0;
            optionsCount = 0;
            attempts = 0;
            currentOptions = [];
            document.querySelector('.option-container > .options').innerHTML = '';
            document.querySelector('#countdown svg circle').classList.remove('circle--10s');
            document.querySelector('.outcome').classList.add("hide")
            document.querySelector('.outcome > .message').innerHTML = '';
            document.querySelector('.outcome > .message').classList.remove("success")
            document.querySelector('.outcome > .message').classList.remove("fail")
            Array.from(document.querySelectorAll('.attempts > div')).forEach((element, index) => {
                element.classList.remove('wrong')
            });
            countdown = 10;
        },
        startUp: () => {
            setTimeout(() => {
                app.showPattern()
            }, 1);
        },
        generateNumber: (min, max) => {
            return Math.floor(Math.random() * (max - min) + min);
        },
        showPattern: () => {
            document.querySelector(".hack-wrap").classList.add("disable-hover")
            currentOptions = [];
            let optionList = document.querySelectorAll('.option');
            optionList.forEach((element, index) => {
                let optionsToGenerate = app.generateNumber(1, hOptions-1);
                let optionsGenerated = 0;
                
                let optionsToBeValid = [];
                for (let i = 0; i < optionsToGenerate; i++) {
                    let randomIndex = app.generateNumber(0,element.children.length);
                    let shouldLoop = true;
                    while (shouldLoop) {
                        if(!optionsToBeValid.includes(randomIndex)) {
                            optionsToBeValid.push(randomIndex);
                            shouldLoop = false;
                        } else {
                            randomIndex = app.generateNumber(0,element.children.length);
                        }
                    }
                }
                Array.from(element.children).forEach((child, cIndex) => {
                    if(!optionsToBeValid.includes(cIndex)) {
                        child.classList.add('notinpattern');
                    } else {
                        child.classList.remove('notinpattern');
                    }
                });
                currentOptions.push(optionsToBeValid)
            });
            setTimeout(() => app.startGame(), 1500);
        },
        startGame: () => {
            document.querySelector(".hack-wrap").classList.remove("disable-hover")
            let optionList = document.querySelectorAll('.option');
            optionList.forEach((element, index) => { 
                element.classList.add('noselect');
                Array.from(element.children).forEach((child, cIndex) => {
                    child.classList.remove('notinpattern');
                });
            });
            optionList[0].classList.remove('noselect');
            document.querySelectorAll('.option div').forEach((element, index) => {
                element.addEventListener("click", function() {
                    if(this.className == '' ) {
                        if(app.checkSelection(Array.from(optionList).indexOf(this.parentNode), 
                                              Array.from(this.parentNode.children).indexOf(this))) {
                            this.className = 'correct';
                            if(currentOptions[currentPosition].length >= 2) {
                                correctSelections++;
                                if(correctSelections == currentOptions[currentPosition].length) { 
                                    app.moveToNext();
                                }
                            } else {
                                app.moveToNext();
                            }

                            PlaySound("beep.mp3", 0.2)
                            
                        } else {
                            this.className = 'error';
                            app.addAttempt();
                        }
                    }
                });
            });
            countdown = 10;
            document.querySelector('#countdown svg circle').classList.add('circle--10s');
            counterObj = setInterval(() => {
                countdown = --countdown;
                if(countdown == 0) {
                    app.sendResult(false, L["session_timed_out"]);
                }
            }, 1000);
        },
        moveToNext: () => {            
            if((currentPosition + 1) != hOptions) {
                let options = document.querySelectorAll(`.option`);
                options[currentPosition].classList.add('noselect');
                currentPosition++;
                options[currentPosition].classList.remove('noselect');
                correctSelections = 0;
            } else {      
                if(rounds == curRound) {
                    app.sendResult(true);
                } else {
                    curRound++;
                    if(vOptions != hOptions) {
                        vOptions++;
                    } else {
                        hOptions++;
                    }
                    app.generateGrid();
                }
                document.querySelector('.options').innerHTML = '<div class="effect"></div>';
                document.querySelector('#countdown svg circle').classList.remove('circle--10s');
                clearInterval(counterObj);
            }
        },
        sendResult: (result, reason) => {
            document.querySelector('.outcome').classList.remove("hide")
            let message = document.querySelector('.outcome > .message');
            if(result) {
                message.classList.add("success")
                message.innerHTML = L["hack_successful"];
                setTimeout(() => $.post('https://exp_hack/success', JSON.stringify({})), 2500)
            } else {
                message.classList.add("fail")
                message.innerHTML = L["hack_failed"];
                if(typeof reason !== 'undefined') {
                    message.innerHTML += `<br>${reason}`;
                }
                document.querySelector('#countdown svg circle').classList.remove('circle--10s');
                clearInterval(counterObj)
                setTimeout(() => $.post('https://exp_hack/failure', JSON.stringify({})), 2500)
            }
        },
        addAttempt: () => {
            PlaySound("error.mp3", 0.5)
            let attemptElm = document.querySelector('.attempts')
            attemptElm.children[attempts].className = 'wrong';
            if((attempts + 1) == 3) {
                let childToShow = document.querySelectorAll(`.option`);
                Array.from(childToShow).forEach((element, index) => {
                    element.classList.add('noselectfail')
                });
                app.sendResult(false, L["session_terminated"]);
            } else {
                attempts++;
            }
        },
        checkSelection: (parent, selectedIndex) => {
            if(Array.from(currentOptions[parent]).includes(selectedIndex)) {
                return true;
            } else {
                return false;
            }
        },
        generateGrid: () => {
            currentPosition = 0;
            correctSelections = 0;
            let options = document.querySelector('.options');
            let hTimeout = 250, vTimeout = 300;
            for(let i = 0; i < hOptions; i++) {
                setTimeout(() => {
                    let option = document.createElement('div')
                    option.className = 'option';
                    for(let j = 0; j < vOptions; j++) {
                        let oDiv = document.createElement('div');
                        oDiv.className = 'notinpattern';
                        oDiv.innerText = randomLetter()
                        if(j != 0) {
                            oDiv.className += ' hide';
                        }
                        option.append(oDiv);
                    }
                    options.append(option);
                    PlaySound("pop.mp3", 0.5)
                }, hTimeout);
                hTimeout = hTimeout + 250;
            }
            setTimeout(() => {
                for(let i = 1; i < hOptions; i++) {
                    setTimeout(() => {
                        let childToShow = document.querySelectorAll(`.option div:nth-child(${i + 1})`);
                        Array.from(childToShow).forEach((element, index) => {
                            element.className = 'notinpattern';
                        });
                        PlaySound("pop.mp3", 0.5)
                    }, vTimeout);
                    vTimeout = vTimeout + 300;
                }
                setTimeout(() => app.startUp(), vTimeout + 100)
            }, hTimeout)
        }
    }
}();

function randomLetter() {
    const characters = "abcdefghijklmnopqrstuvwxyz"
    let result = ""
  
    result += characters.charAt(Math.floor(Math.random() * characters.length))
    return result
}

function PlaySound(sound, volume) {
    var sound = new Audio(`https://cfx-nui-exp_hack/client/ui/sounds/${sound}`)
    sound.volume = volume || 1.0
    sound.play()
    return sound
}

$(function() {
    $.post("https://exp_hack/GetLocales", "", function(locales) {
        L = locales
    })
})