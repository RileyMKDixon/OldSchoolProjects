/*
 * Copyright (c) 2017. Team rmdixon - CMPUT 301. University of Alberta - All rights reserved.
 * You may use, distribute, or modify this code under terms and conditions of the Code of Student Behaviour at University of Alberta.
 * You may find a copy of this licence in this project.  Otherwise please contact rmdixon@ualberta.ca.
 */

package com.example.rileydixon.assignment1;

import java.io.Serializable;
import java.util.Date;

/**
 * The Counter base class that is sued to keep track of the various counters
 * and the methods used to manipulate the Counter's data fields.
 */

public class Counter implements Serializable{
    private String counterName;
    private Integer currentValue;
    private Integer initialValue;
    private String comment;
    private Date dateLastModified;

    /**
     * Constructs a new Counter variable. Used namely for creating a dummyCounter
     * when editing an actual counter.

     * @param counterName The new Counter's name.
     * @param currentValueStr The new Counter's currentValue.
     * @param initialValueStr The new Counter's initial value.
     * @param comment The new Counter's comment.
     * @throws NegativeNumberException If the initial or current value entered is Negative
     *                                 throw this exception and notify the user of their error.
     * @throws EmptyStringException If a required data field is left empty, notify the user.
     */
    public Counter(String counterName, String currentValueStr, String initialValueStr, String comment) throws NegativeNumberException, EmptyStringException{
        setCounterName(counterName);
        setCurrentValue(currentValueStr);
        setInitialValue(initialValueStr);
        setComment(comment);
    }

    /**
     * Constructs a new Counter variable.

     * @param counterName The new Counter's name.
     * @param initialValueStr The new Counter's initial value.
     * @param comment The new Counter's comment.
     * @throws NegativeNumberException If the initial or current value entered is Negative
     *                                 throw this exception and notify the user of their error.
     * @throws EmptyStringException If a required data field is left empty, notify the user.
     */
    public Counter(String counterName, String initialValueStr, String comment) throws NegativeNumberException, EmptyStringException {
        //When creating a Counter object, currentValue defaults to initialValue.
        //The user does not have access to change the date the counter was last modified.

        setCounterName(counterName);
        setCurrentValue(initialValueStr);
        setInitialValue(initialValueStr);
        setComment(comment);
        this.dateLastModified = new Date();
    }

    /**
     * Returns this Counter's name.
     *
     * @return the Counter's name.
     */
    public String getCounterName() {
        return counterName;
    }

    /**
     * Sets this Counter's name.
     *
     * @param counterName The name the Counter should be set to.
     * @throws EmptyStringException If the name field is empty notify the user.
     */
    public void setCounterName(String counterName) throws EmptyStringException{
        if(counterName.length() < 1){
            throw new EmptyStringException("Counter name field left empty");
        }
        this.counterName = counterName;
    }

    /**
     * Returns the Counter's current value.
     *
     * @return Return the Counter's current value as an Integer.
     *
     */
    public Integer getCurrentValue() {
        return currentValue;
    }

    /**
     * Sets the Counter's current value.
     * @param currentValueStr The string from the text view.
     * @throws NegativeNumberException If the number received is negative, notify the user.
     * @throws EmptyStringException If the string is empty, notify the user.
     */
    public void setCurrentValue(String currentValueStr) throws NegativeNumberException, EmptyStringException{
        if(currentValueStr.length() < 1){
            throw new EmptyStringException("Empty Data Field");
        }

        Integer currentValue = Integer.parseInt(currentValueStr);

        if(currentValue < 0){
            throw new NumberFormatException("Non-positive Number Entered");
        }
        this.currentValue = currentValue;
    }

    /**
     * Gets the Counter's initial value.
     *
     * @return The initial value as an Integer.
     */
    public Integer getInitialValue() {
        return initialValue;
    }

    /**
     * Sets the initial value of the Counter.
     *
     * @param initialValueStr The string from the text View.
     * @throws NegativeNumberException If the number recieived is negative, notify the user.
     * @throws EmptyStringException If the string received is empty, notify the user.
     */
    public void setInitialValue(String initialValueStr) throws NegativeNumberException, EmptyStringException{
        if(initialValueStr.length() < 1){
            throw new EmptyStringException("Empty Data Field");
        }

        Integer initialValue = Integer.parseInt(initialValueStr);

        if(initialValue < 0){
            throw new NumberFormatException("Non-positive Number Entered");
        }
        this.initialValue = initialValue;
    }

    /**
     * Returns the comment associated with the Counter.
     *
     * @return The comment from the Counter.
     */
    public String getComment() {
        return comment;
    }

    /**
     * Sets the Counter's comment field.
     *
     * @param comment The comment from the Counter.
     */
    public void setComment(String comment) {
        this.comment = comment;
    }

    /**
     * Returns the time when the counter was last modified.
     *
     * @return A Date object with the time the Counter was last modified.
     */
    public Date getDateLastModified() {
        return dateLastModified;
    }

    /**
     * Sets the time the Counter was last modified to the current time.
     */
    public void setDateLastModified() {
        this.dateLastModified = new Date();
    }

    /**
     * Increases the Counter's current count by 1.
     */
    public void incrementCounter(){
        this.currentValue++;
        if(this.currentValue < 0){ //Protection in the unlikely case of overflow.
            this.currentValue = 0;
        }else{
            this.setDateLastModified();
        }
    }

    /**
     * Decreases the Counter's current count by 1.
     */
    public void decrementCounter(){
        this.currentValue--;
        if(this.currentValue < 0){
            this.currentValue = 0;
        }else{
            this.setDateLastModified();
        }
    }

    /**
     * Resets the Counter's current count to it's initial value.
     */
    public void resetCounter(){
        this.currentValue = this.initialValue;
    }

    /**
     * Returns the Counter's data as it's name, followed by the current value,
     * followed by the date it was last modified.
     * @return A string containing the Counter's state.
     */
    @Override
    public String toString(){
        return this.counterName + ": " + this.currentValue + "\n" + this.dateLastModified;
    }

}
