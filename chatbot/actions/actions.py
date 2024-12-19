# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


# This is a simple example for a custom action which utters "Hello World!"

# from typing import Any, Text, Dict, List
#
# from rasa_sdk import Action, Tracker
# from rasa_sdk.executor import CollectingDispatcher
#
#
# class ActionHelloWorld(Action):
#
#     def name(self) -> Text:
#         return "action_hello_world"
#
#     def run(self, dispatcher: CollectingDispatcher,
#             tracker: Tracker,
#             domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
#
#         dispatcher.utter_message(text="Hello World!")
#
#         return []

from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
import mysql.connector
from mysql.connector import Error

class ActionGetAdminAnswer(Action):
    def name(self) -> Text:
        return "action_get_admin_answer"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
            
        try:
            # Get latest user message
            user_message = tracker.latest_message.get('text')
            
            # Connect to the database
            connection = mysql.connector.connect(
                host='localhost',
                port=3307,  # Specify the correct port
                database='chatbot_db',
                user='root',
                password=''
            )
            
            if connection.is_connected():
                cursor = connection.cursor(dictionary=True)
                
                # Get all predefined questions and their keywords
                cursor.execute("""
                    SELECT id, question_text, keywords
                    FROM predefined_questions
                """)
                questions = cursor.fetchall()
                
                # Find matching question based on keywords
                matched_question_id = None
                for question in questions:
                    keywords = eval(question['keywords'])  # Consider replacing eval with a safer method
                    if any(keyword.lower() in user_message.lower() for keyword in keywords):
                        matched_question_id = question['id']
                        break
                
                if matched_question_id:
                    # Get all admin answers for this question
                    cursor.execute("""
                        SELECT a.answer, ad.username 
                        FROM admin_answers a
                        JOIN admins ad ON a.admin_id = ad.id
                        WHERE a.question_id = %s AND a.active = 1
                    """, (matched_question_id,))
                    
                    answers = cursor.fetchall()
                    
                    if answers:
                        # Return first active answer found
                        dispatcher.utter_message(text=answers[0]['answer'])
                    else:
                        dispatcher.utter_message(text="I don't have an answer for that question yet.")
                else:
                    dispatcher.utter_message(text="I couldn't understand your question. Please try rephrasing it.")
                    
        except Error as e:
            print(f"Database error: {e}")
            dispatcher.utter_message(text="Sorry, I'm having trouble accessing my knowledge base.")
            
        finally:
            if 'connection' in locals() and connection.is_connected():
                cursor.close()
                connection.close()
                
        return []
