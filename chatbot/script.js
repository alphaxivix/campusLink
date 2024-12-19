async function sendMessage() {
  const userInput = document.getElementById('user-input');
  const message = userInput.value.trim();
  if (message === '') return;

  // Append user message to chat box
  appendMessage(message, 'user-message');

  // Clear input field
  userInput.value = '';

  // Send message to Rasa server
  const response = await fetch('http://localhost:5005/webhooks/rest/webhook', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ sender: 'user', message: message })
  });

  const data = await response.json();
  data.forEach((botMessage) => {
    appendMessage(botMessage.text, 'bot-message');
  });
}

function appendMessage(message, className) {
  const chatBox = document.getElementById('chat-box');
  const messageElement = document.createElement('div');
  messageElement.className = `message ${className}`;
  messageElement.textContent = message;
  chatBox.appendChild(messageElement);
  chatBox.scrollTop = chatBox.scrollHeight;
}