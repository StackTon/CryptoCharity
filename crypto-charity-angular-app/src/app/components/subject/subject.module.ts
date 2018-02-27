import { NgModule } from "@angular/core";
import { CommonModule } from "@angular/common";
import { RouterModule } from "@angular/router";

import { subjectsComponents } from './index';
import { HttpClientModule } from "@angular/common/http";
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

@NgModule({
    declarations: [
      ...subjectsComponents
    ],
    imports: [
      CommonModule,
      RouterModule,
      HttpClientModule,
      BrowserAnimationsModule
    ]
  })
  export class SubjectModule {  }