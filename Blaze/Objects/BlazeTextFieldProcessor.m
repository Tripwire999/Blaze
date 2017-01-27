//
//  BlazeTextFieldProcessor.m
//  Blaze
//
//  Created by Bob de Graaf on 27-01-17.
//  Copyright © 2017 GraafICT. All rights reserved.
//

#import "BlazeTextFieldProcessor.h"

@interface BlazeTextFieldProcessor () <UITextFieldDelegate>
{
    
}

@end

@implementation BlazeTextFieldProcessor

-(void)update
{
    //Formatter
    if(self.row.formatter) {
        if([self.row.formatter isKindOfClass:[NSNumberFormatter class]]) {
            self.textField.text =  [((NSNumberFormatter *)self.row.formatter) stringFromNumber:self.row.value];
        }
        else {
            self.textField.text = [self.row.formatter stringForObjectValue:self.row.value];
        }
    }
    else {
        self.textField.text = self.row.value;
    }
    
    //Suffix
    if(self.row.textFieldSuffix.length) {
        self.textField.text = [self.textField.text stringByAppendingString:self.row.textFieldSuffix];
    }
    
    //Properties
    self.textField.keyboardType = self.row.keyboardType;
    self.textField.secureTextEntry = self.row.secureTextEntry;
    self.textField.autocorrectionType = self.row.autocorrectionType;
    self.textField.autocapitalizationType = self.row.capitalizationType;
    
    //Merge BlazeRow's configuration with the BlazeTextField
    [self.textField mergeBlazeRowWithInspectables:self.row];
    
    //Editable
    self.textField.userInteractionEnabled = !self.row.disableEditing;
    
    //Update
    self.textField.delegate = self;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.row.textFieldSuffix.length) {
        textField.text = [textField.text stringByReplacingOccurrencesOfString:self.row.textFieldSuffix withString:@""];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(self.row.textFieldSuffix.length) {
        textField.text = [textField.text stringByAppendingString:self.row.textFieldSuffix];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.row.value = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(self.row.formatter) {
        if([self.row.formatter isKindOfClass:[NSNumberFormatter class]]) {
            self.row.value = [self.row.value stringByReplacingOccurrencesOfString:@"," withString:@"."];
            textField.text = self.row.value;
            self.row.value = [((NSNumberFormatter *)self.row.formatter) numberFromString:self.row.value];
        }
        else {
            self.row.value = [self.row.formatter stringForObjectValue:self.row.value];
            textField.text = self.row.value;
        }
        [self.row updatedValue:self.row.value];
        return FALSE;
    }
    [self.row updatedValue:self.row.value];
    return TRUE;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.row.doneChanging) {
        self.row.doneChanging();
    }
    if(self.cell.nextField) {
        self.cell.nextField();
    }
    else {
        [textField resignFirstResponder];
    }
    return TRUE;
}


@end
