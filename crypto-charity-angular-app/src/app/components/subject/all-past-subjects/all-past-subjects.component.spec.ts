import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AllPastSubjectsComponent } from './all-past-subjects.component';

describe('AllPastSubjectsComponent', () => {
  let component: AllPastSubjectsComponent;
  let fixture: ComponentFixture<AllPastSubjectsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AllPastSubjectsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AllPastSubjectsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
