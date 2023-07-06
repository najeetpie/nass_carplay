var vehId = null;
var vehIdStr = null;
var songTotal = 0;
document.addEventListener('DOMContentLoaded', () => {
  window.addEventListener('message', function(event) {
    var item = event.data;
    if (item.event == "openCarPlay") {
      vehId = item.veh;
      vehIdStr = item.vehIdStr;

      if(item.queue != null){
        var songList = document.querySelector(".nextcontainer .song-list");
        item.queue.forEach(function(item) {
          var songListItem = document.createElement("li");
          songListItem.textContent = item.songName
          songList.appendChild(songListItem);


          songListItem.addEventListener("click", function() {
            $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
              event: 'forceurl',
              veh: vehId,
              vehStr: vehIdStr,
              link: item.link,
              queuePos: Array.from(songList.children).indexOf(songListItem)+1,
              songName: item.songName
            }));
          });
        });
      } 


      const mainContainer = document.getElementById('maincontainer');
      mainContainer.style.display = 'block';
      mainContainer.style.opacity = '0';
      mainContainer.style.transform = 'scale(0.8)';
      mainContainer.style.transition = 'none';
      setTimeout(() => {
        mainContainer.style.transition = 'all 0.5s ease-in-out';
        mainContainer.style.opacity = '1';
        mainContainer.style.transform = 'scale(1)';
      }, 100);
    }else if(item.event == "playbackStarted"){
      $.getJSON('https://noembed.com/embed?url=', {format: 'json', url: item.link}, function (data) {
        var songNameElement = document.getElementById("songname");
        songNameElement.textContent = data.title;
        
        var authorElement = document.getElementById("author");
        authorElement.textContent = "by " + data.author_name;

        document.getElementById('musicthumbanil').src = data.thumbnail_url;
		
      });

      document.querySelector('.volume-pill').style.height = `${(item.vol*100)}%`;

    }else if(item.event == "updateTime"){
      if(songTotal != item.time.totalDuration){
        songTotal = item.time.totalDuration;
      }
      updateMusicProg(item.time.currentTime, item.time.totalDuration)
    }else if(item.event == "resetPlayback"){
      resetPlayback();
    }else if(item.event == "nextSong") {
      nextSong();
    }else if(item.event == "setPicPaused"){
      $('.btn3').addClass('btn').removeClass('btn3').html('<i class="fas fa-play"></i>');
    }
  });
});

$(document).keyup(function(event) {
  if (event.which == 27) {
      closeMenu()
      return
  }
});

document.addEventListener('DOMContentLoaded', () => {
  //Back Button
  const backButton = document.querySelector('.backcont button');
  backButton.addEventListener('click', () => {
    closeMenu();
  }); 

  //Music Selector
  const form = document.querySelector('.song-form');
  form.addEventListener('submit', (event) => {
  event.preventDefault();

	const songInput = document.querySelector('.song-input');
	const songLink = songInput.value;

  $.getJSON('https://noembed.com/embed', {format: 'json', url: songLink}, function (data) {
			var songListItem = document.createElement("li");
			songListItem.textContent = data.title + " by " + data.author_name;

			var songList = document.querySelector(".nextcontainer .song-list");
			songList.appendChild(songListItem);
      var isSwitching = false; 
      var switchingTime = 1000;


      songListItem.addEventListener("click", function() {
        if (isSwitching) return;
        isSwitching = true;
        $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
          event: 'breakLoop',
          vehStr: vehIdStr,
          veh: vehId,
        }));
        setTimeout(function() {
          isSwitching = false;
        }, switchingTime);
        $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
          event: 'forceurl',
          veh: vehId,
          vehStr: vehIdStr,
          queuePos: Array.from(songList.children).indexOf(songListItem)+1,
          link: songLink,
          songName: data.title + " by " + data.author_name,
          
        }));
      });
      $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
        event: 'url',
        veh: vehId,
        vehStr: vehIdStr,
        link: songLink,
        queuePos: Array.from(songList.children).indexOf(songListItem)+1,
        songName: data.title + " by " + data.author_name,
      }));
      
	});
    songInput.value = '';
  });

  //Volume
  const volumePill = document.querySelector('.volume-pill');
	const volumePillBar = document.querySelector('.volume-pill-bar');

	function setVolume(event) {
	  const boundingRect = volumePillBar.getBoundingClientRect();
	  const mouseY = boundingRect.bottom - event.clientY;
	  const volume = (mouseY / boundingRect.height) * 100;
	  volumePill.style.height = `${volume}%`;
	  volumePill.style.bottom = `0%`;

    $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
      event: 'setVolume',
      veh: vehId,
      vehStr: vehIdStr,
      vol: volume,
    }));
	}

	volumePillBar.addEventListener('click', setVolume);

  const volumenbtn = document.querySelector('.volumenbtn');
	const volumebtnmute = document.querySelector('.volumebtnmute');
	const volumeIcon = document.querySelector('.volumebtns i');
	const volumeBtns = document.querySelector('.volumebtns');
    
	volumenbtn.addEventListener('click', function() {
	  if (this.classList.contains('volumenbtn')) {
		this.classList.remove('volumenbtn');
		this.classList.add('volumebtnmute');
		volumeIcon.classList.remove('fa-volume-up');
		volumeIcon.classList.add('fa-volume-off');

    volumePill.style.height = `${0}%`;
    $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
      event: 'setVolume',
      veh: vehId,
      vehStr: vehIdStr,
      vol: 0,
    }));

	  } else if (this.classList.contains('volumebtnmute')) {
		this.classList.remove('volumebtnmute');
		this.classList.add('volumenbtn');
		volumeIcon.classList.remove('fa-volume-off');
		volumeIcon.classList.add('fa-volume-up');
    volumePill.style.height = `${50}%`;

    $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
      event: 'setVolume',
      veh: vehId,
      vehStr: vehIdStr,
      vol: 50,
    }));
	  }
	});

  //Progress Bar

  const progressBar = document.querySelector('.song-progress');
  const progressFill = document.querySelector('.song-progress-fill');
  const currentTime = document.querySelector('.current-time');

  progressBar.addEventListener('click', function(event) {
    const progressBarRect = progressBar.getBoundingClientRect();
    const clickX = event.clientX - progressBarRect.left;
    const fillWidth = progressBarRect.width;
    const newProgress = (clickX / fillWidth) * 100;

    progressBar.style.width = `${newProgress}%`;
    progressFill.style.width = `${newProgress}%`;
    progressFill.style.backgroundImage = `linear-gradient(to right, #ffffff ${newProgress}%, #ffffff ${newProgress}%)`;

    const newTime = (newProgress / 100) * songTotal;
    const minutes = Math.floor(newTime / 60);
    const seconds = Math.floor(newTime % 60);
    currentTime.textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`;

    $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
      event: 'selectTime',
      veh: vehId,
      vehStr: vehIdStr,
      newTime: newTime,
    }));
  });
});
	 
function closeMenu() {
  var songList = document.querySelector(".nextcontainer .song-list");


  while (songList.hasChildNodes()) {
    songList.removeChild(songList.firstChild);
  }

  $.post(`https://${GetParentResourceName()}/closeCarPlay`);
  const mainContainer = document.getElementById('maincontainer');
  mainContainer.style.transition = 'all 0.5s ease-out';
  mainContainer.style.opacity = '0';
  mainContainer.style.transform = 'scale(0.8)';

  setTimeout(() => {
    mainContainer.style.display = 'none';
  }, 500);
}

$(document).ready(function() {
  $('.btn').click(function() {
    if ($(this).hasClass('btn')) {
      $(this).addClass('btn3').removeClass('btn').html('<i class="fas fa-pause"></i>');
      $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
        event: 'resume',
        vehStr: vehIdStr,
        veh: vehId,
      }));
    } else  if ($(this).hasClass('btn3')) {
      $(this).addClass('btn').removeClass('btn3').html('<i class="fas fa-play"></i>');
      $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
        event: 'pause',
        vehStr: vehIdStr,
        veh: vehId,
      }));
    }
  });

  window.addEventListener('message', function(event) {
    var item = event.data;
    if (item.event == "playbackStarted") {
      $('.btn').addClass('btn3').removeClass('btn').html('<i class="fas fa-pause"></i>');
    } else if (item.event == "pause") {
      $('.btn3').addClass('btn').removeClass('btn3').html('<i class="fas fa-play"></i>');
    }
  });
});

let buttonClicked = false;

function nextSong(){
  $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
    event: 'breakLoop',
    vehStr: vehIdStr,
    veh: vehId,
  }));
  $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
    event: 'nextSong',
    vehStr: vehIdStr,
    veh: vehId
  }));
}


function backSong(){
  $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
    event: 'restartSong',
    vehStr: vehIdStr,
    veh: vehId,
  }));
}

function resetPlayback(){
  var songNameElement = document.getElementById("songname");
  songNameElement.textContent = "No media present";
  
  var authorElement = document.getElementById("author");
  authorElement.textContent = "";

  document.getElementById('musicthumbanil').src = "https://i.imgur.com/M5Lnw3o.png";

  $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
    event: 'resetPlayback',
    vehStr: vehIdStr,
    veh: vehId,
  }));

  updateMusicProg(0, 0)
}

function updateMusicProg(curr, total) {
  const progressBar = document.querySelector('.song-progress');
  const progressFill = document.querySelector('.song-progress-fill');
  const currentTime = document.querySelector('.current-time');
  const songLength = document.querySelector('.song-length');

  const progress = (curr / total) * 100;

  progressBar.style.width = `${progress}%`;

  progressFill.style.width = `${progress}%`;
  progressFill.style.backgroundImage = `linear-gradient(to right, #ffffff ${progress}%, #ffffff ${progress}%)`;

  const minutes = Math.floor(curr / 60);
  const seconds = Math.floor(curr % 60);
  currentTime.textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`;

  const lengthMinutes = Math.floor(total / 60);
  const lengthSeconds = Math.floor(total % 60);
  songLength.textContent = `${lengthMinutes}:${lengthSeconds.toString().padStart(2, '0')}`;
}














