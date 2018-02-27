import { Routes } from '@angular/router';

import { HomeComponent } from './components/home/home.component';
import { InfoComponent } from './components/info/info.component';
import { AllSubjectsComponent } from './components/subject/all-subjects/all-subjects.component';
import { AllPastSubjectsComponent } from './components/subject/all-past-subjects/all-past-subjects.component';
import { DetailsComponent } from './components/subject/details/details.component';
import { NotFoundComponent } from './components/shared/not-found/not-found.component';

export const routes: Routes = [
    { path: '', component: HomeComponent, pathMatch: 'full' },
    { path: 'info', component: InfoComponent, },
    { path: 'subjects', component: AllSubjectsComponent },
    { path: 'past-subjects', component: AllPastSubjectsComponent },
    { path: 'subject/:index', component: HomeComponent },
    { path: '', component: NotFoundComponent }
]