// assets/js/socket.js
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()

// Find our HTML elements once
const audioPlayer = document.getElementById("audio-player");
const titleEl = document.getElementById("now-playing-title");
const artistEl = document.getElementById("now-playing-artist");

// Now connect to the channel
let channel = socket.channel("now_playing:lobby", {})

// This function updates the page with new track info
const updateTrack = (payload) => {
  if (payload.current_track) {
    console.log("New song received:", payload.current_track.title);
    // Update the text on the page
    titleEl.innerText = payload.current_track.title;
    artistEl.innerText = payload.current_track.artist;

    // Update the audio player's source and play it
    audioPlayer.src = payload.current_track.url;
    audioPlayer.play().catch(error => {
      console.log("Autoplay was prevented by the browser. User must click play.", error);
    });
  } else {
    // Handle the case where nothing is playing
    titleEl.innerText = "Radio Offline";
    artistEl.innerText = "";
    audioPlayer.src = "";
  }
}

// Listen for the "new_song" event from the server
channel.on("new_song", payload => {
  updateTrack(payload);
})

// Join the channel and log if it succeeds or fails
channel.join()
  .receive("ok", resp => { console.log("Joined channel successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
