import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import { CommonModule } from '@angular/common/';
import { SharedModule } from './components/shared/shared.module';
import { SubjectModule } from './components/subject/subject.module';
import { RouterModule } from "@angular/router";


import { AppComponent } from './app.component';
import { routes } from "./app.routing";

import { HomeComponent } from './components/home/home.component';
import { InfoComponent } from './components/info/info.component';




@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    InfoComponent
  ],
  imports: [
    BrowserModule,
    CommonModule,
    HttpClientModule,
    SharedModule,
    SubjectModule,
    RouterModule.forRoot(routes),
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
